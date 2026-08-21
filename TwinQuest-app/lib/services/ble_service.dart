import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
  import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';
import 'package:permission_handler/permission_handler.dart';

enum ProximityLevel {
  far,
  close,
  touch,
}

class BLEService {
  Timer? _partnerTimeoutTimer;
  static final BLEService _instance = BLEService._internal();

  factory BLEService() => _instance;

  BLEService._internal();

  static const int _manufacturerId = 0x5451;

  // TQ + 8 chars pair ID + 8 chars player ID
  static const List<int> _magic = [0x54, 0x51];

  final FlutterBlePeripheral _peripheral = FlutterBlePeripheral();

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

    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
    ].request();

    debugPrint('BLE PERMISSION STATUSES: $statuses');

    return statuses.values.every(
          (status) => status.isGranted || status.isLimited,
    );
  }

  static ProximityLevel rssiToLevel(int rssi) {
    if (rssi >= -55) {
      return ProximityLevel.touch;
    } else if (rssi >= -75) {
      return ProximityLevel.close;
    } else {
      return ProximityLevel.far;
    }
  }

  static double rssiToDistance(
      int rssi, {
        int txPower = -59,
      }) {
    if (rssi == 0) return -1.0;

    final ratio = rssi / txPower;

    if (ratio < 1.0) {
      return pow(ratio, 10).toDouble();
    }

    return (0.89976) * pow(ratio, 7.7095) + 0.111;
  }

  static int distanceToRssi(double distanceMeters) {
    if (distanceMeters <= 0.2) return -42;
    if (distanceMeters <= 0.8) return -52;
    if (distanceMeters <= 2.5) return -68;
    if (distanceMeters <= 5.0) return -78;
    return -88;
  }

  String _suffix(String value) {
    if (value.length <= 8) {
      return value.padLeft(8, '0');
    }

    return value.substring(value.length - 8);
  }

  Uint8List _buildAdvertisementData({
    required String pairId,
    required String playerId,
  }) {
    final pairSuffix = _suffix(pairId);
    final playerSuffix = _suffix(playerId);

    final payload = [
      ..._magic,
      ...utf8.encode(pairSuffix),
      ...utf8.encode(playerSuffix),
    ];

    return Uint8List.fromList(payload);
  }

  bool _isTwinQuestAdvertisement(
      Map<int, List<int>> manufacturerData,
      ) {
    final data = manufacturerData[_manufacturerId];

    if (data == null || data.length < 18) {
      return false;
    }

    return data[0] == _magic[0] && data[1] == _magic[1];
  }

  String? _readPairSuffix(Map<int, List<int>> manufacturerData) {
    final data = manufacturerData[_manufacturerId];

    if (data == null || data.length < 18) {
      return null;
    }

    return utf8.decode(data.sublist(2, 10), allowMalformed: true);
  }

  String? _readPlayerSuffix(Map<int, List<int>> manufacturerData) {
    final data = manufacturerData[_manufacturerId];

    if (data == null || data.length < 18) {
      return null;
    }

    return utf8.decode(data.sublist(10, 18), allowMalformed: true);
  }

  Future<void> startAdvertising({
    required String pairId,
    required String playerId,
  }) async {
    if (kIsWeb || _isSimulatedMode) {
      return;
    }

    final permission = await requestPermissions();

    if (!permission) {
      throw Exception('Bluetooth permissions were not granted');
    }

    final supported = await _peripheral.isSupported;

    if (!supported) {
      throw Exception('This device does not support BLE advertising');
    }

    final data = _buildAdvertisementData(
      pairId: pairId,
      playerId: playerId,
    );

    try {
      await _peripheral.stop();
    } catch (_) {}

    await _peripheral.start(
      advertiseData: AdvertiseData(
        manufacturerId: _manufacturerId,
        manufacturerData: data,
      ),
      advertiseSettings: AdvertiseSettings(
        connectable: false,
        advertiseMode: AdvertiseMode.advertiseModeLowLatency,
        txPowerLevel: AdvertiseTxPower.advertiseTxPowerHigh,
      ),
    );

    debugPrint(
      'BLE: advertising started '
          'pair=${_suffix(pairId)} '
          'player=${_suffix(playerId)}',
    );
  }

  Future<void> startProximityMonitoring({
    required String targetPairId,
    required String playerId,
    required Function(
        int rssi,
        ProximityLevel level,
        double estimatedDistance,
        ) onUpdate,
  }) async {
    await stopMonitoring();

    if (_isSimulatedMode) {
      _simulationTimer = Timer.periodic(
        const Duration(milliseconds: 600),
            (_) {
          final rssi = distanceToRssi(_simulatedDistanceMeters);
          final level = rssiToLevel(rssi);

          onUpdate(
            rssi,
            level,
            _simulatedDistanceMeters,
          );
        },
      );

      return;
    }

    final permission = await requestPermissions();

    if (!permission) {
      debugPrint('BLE: permissions denied');
      return;
    }

    // IMPORTANT:
    // Both phones advertise their own identity.
    await startAdvertising(
      pairId: targetPairId,
      playerId: playerId,
    );

    // Listen BEFORE starting the scan.
    _scanSubscription = FlutterBluePlus.onScanResults.listen(
          (results) {
        for (final result in results) {
          final advertisement =
              result.advertisementData.manufacturerData;
          debugPrint(
            'BLE SCAN: device=${result.device.remoteId} '
                'rssi=${result.rssi} '
                'manufacturerData=$advertisement',
          );
          if (!_isTwinQuestAdvertisement(advertisement)) {
            continue;
          }

          final advertisedPair =
          _readPairSuffix(advertisement);

          final advertisedPlayer =
          _readPlayerSuffix(advertisement);

          if (advertisedPair == null ||
              advertisedPlayer == null) {
            continue;
          }

          final expectedPair = _suffix(targetPairId);
          final ownPlayer = _suffix(playerId);

          // Ignore advertisements from another event.
          if (advertisedPair != expectedPair) {
            continue;
          }

          // Ignore our own phone.
          if (advertisedPlayer == ownPlayer) {
            continue;
          }

          final rssi = result.rssi;
          final level = rssiToLevel(rssi);
          final distance = rssiToDistance(rssi);

          debugPrint(
            'BLE PARTNER FOUND: '
                'player=$advertisedPlayer '
                'rssi=$rssi '
                'distance=${distance.toStringAsFixed(2)}m',
          );
          _partnerTimeoutTimer?.cancel();

          _partnerTimeoutTimer = Timer(
            const Duration(seconds: 2),
                () {
              debugPrint('BLE: partner advertisement timed out');

              onUpdate(
                -100,
                ProximityLevel.far,
                15.0,
              );
            },
          );
          onUpdate(
            rssi,
            level,
            distance,
          );
        }
      },
      onError: (error) {
        debugPrint('BLE scan error: $error');
      },
    );

    await FlutterBluePlus.startScan(
      androidUsesFineLocation: true,
      continuousUpdates: true,
    );

    debugPrint(
      'BLE: scanning started for pair ${_suffix(targetPairId)}',
    );
  }

  Future<void> stopMonitoring() async {
    _simulationTimer?.cancel();
    _simulationTimer = null;

    await _scanSubscription?.cancel();
    _scanSubscription = null;

    try {
      await FlutterBluePlus.stopScan();
    } catch (_) {}

    try {
      await _peripheral.stop();
    } catch (_) {}

    debugPrint('BLE: monitoring + advertising stopped');
  }
}