import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

enum ProximityLevel {
  far, // 🔵 Blue - Partner is far away
  close, // 🔴 Red - Very close to partner
  touch, // 🟢 Green - Touch phones together
}

class BLEService {
  static final BLEService _instance = BLEService._internal();
  factory BLEService() => _instance;
  BLEService._internal();

  StreamSubscription<List<ScanResult>>? _scanSubscription;
  Timer? _simulationTimer;

  bool _isSimulatedMode = false;
  double _simulatedDistanceMeters = 8.0;

  bool get isSimulatedMode => _isSimulatedMode;
  double get simulatedDistance => _simulatedDistanceMeters;

  void setSimulatedMode(bool enabled) {
    _isSimulatedMode = enabled;
  }

  void updateSimulatedDistance(double meters) {
    _simulatedDistanceMeters = meters.clamp(0.1, 15.0);
  }

  Future<bool> requestPermissions() async {
    if (kIsWeb) return true;
    
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();

    return statuses.values.every(
      (status) => status.isGranted || status.isLimited,
    );
  }

  /// Categorize RSSI value to proximity level
  static ProximityLevel rssiToLevel(int rssi) {
    if (rssi >= -55) {
      return ProximityLevel.touch;
    } else if (rssi >= -75) {
      return ProximityLevel.close;
    } else {
      return ProximityLevel.far;
    }
  }

  /// Estimate distance in meters from RSSI
  static double rssiToDistance(int rssi, {int txPower = -59}) {
    if (rssi == 0) return -1.0;
    double ratio = rssi * 1.0 / txPower;
    if (ratio < 1.0) {
      return pow(ratio, 10).toDouble();
    } else {
      return (0.89976) * pow(ratio, 7.7095) + 0.111;
    }
  }

  /// Convert distance in meters to approximate RSSI
  static int distanceToRssi(double distanceMeters) {
    if (distanceMeters <= 0.2) return -42;
    if (distanceMeters <= 0.8) return -52;
    if (distanceMeters <= 2.5) return -68;
    if (distanceMeters <= 5.0) return -78;
    return -88;
  }

  void startProximityMonitoring({
    required String targetPairId,
    required Function(int rssi, ProximityLevel level, double estimatedDistance) onUpdate,
  }) {
    stopMonitoring();

    if (_isSimulatedMode) {
      _simulationTimer = Timer.periodic(const Duration(milliseconds: 600), (timer) {
        int rssi = distanceToRssi(_simulatedDistanceMeters);
        ProximityLevel level = rssiToLevel(rssi);
        onUpdate(rssi, level, _simulatedDistanceMeters);
      });
      return;
    }

    // Real BLE Scan
    FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 30),
      androidUsesFineLocation: true,
    );

    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult r in results) {
        String deviceName = r.device.platformName;
        String advertisementData = r.advertisementData.advName;
        
        if (deviceName.contains(targetPairId) || advertisementData.contains(targetPairId)) {
          int rssi = r.rssi;
          ProximityLevel level = rssiToLevel(rssi);
          double dist = rssiToDistance(rssi);
          onUpdate(rssi, level, dist);
          break;
        }
      }
    });
  }

  void stopMonitoring() {
    _simulationTimer?.cancel();
    _simulationTimer = null;
    _scanSubscription?.cancel();
    _scanSubscription = null;
    try {
      FlutterBluePlus.stopScan();
    } catch (_) {}
  }
}
