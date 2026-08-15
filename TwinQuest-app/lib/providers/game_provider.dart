import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/ble_service.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

enum GamePhase {
  home,
  joinEvent,
  waiting,
  pairing,
  closer,
  touchMatch,
  matchResult,
}

class GameProvider extends ChangeNotifier {
  final BLEService _bleService = BLEService();

  // State Variables
  GamePhase _phase = GamePhase.home;
  String _playerName = 'Volunteer';
  String _eventCode = 'ORIENT26';
  String _playerId = '';
  String _pairId = '';
  String _pairPin = '1042';
  String _partnerName = 'Mystery Partner';
  String _partnerAvatar = '🌟';
  String _imageHalf = 'LEFT';
  final String _imageAsset = 'assets/images/puzzle_landscape.png';
  String _avatar = '⚡';

  // Unique per-pair image (only known once the match is completed & verified).
  // Base64 data-uri strings ("data:image/png;base64,...") as returned by the backend.
  String? _revealedLeftImage;
  String? _revealedRightImage;

  // Proximity State
  int _rssi = -80;
  ProximityLevel _proximityLevel = ProximityLevel.far;
  double _estimatedDistance = 8.0;

  // Touch Lock Progress
  int _touchElapsedMs = 0;
  double _touchProgress = 0.0;
  Timer? _touchTimer;
  final int touchRequiredDurationMs = 3000; // 3 seconds touch hold

  // Stopwatch & Timer
  final Stopwatch _matchStopwatch = Stopwatch();
  String _formattedTime = '00:00.00';
  int _finalDurationMs = 0;
  Timer? _matchTicker;
  Timer? _lobbyPollingTimer;

  // Leaderboard data
  List<dynamic> _leaderboard = [];

  // Getters
  GamePhase get phase => _phase;
  String get playerName => _playerName;
  String get eventCode => _eventCode;
  String get playerId => _playerId;
  String get pairId => _pairId;
  String get pairPin => _pairPin;
  String get partnerName => _partnerName;
  String get partnerAvatar => _partnerAvatar;
  String get imageHalf => _imageHalf;
  String get imageAsset => _imageAsset;
  String get avatar => _avatar;
  String? get revealedLeftImage => _revealedLeftImage;
  String? get revealedRightImage => _revealedRightImage;

  int get rssi => _rssi;
  ProximityLevel get proximityLevel => _proximityLevel;
  double get estimatedDistance => _estimatedDistance;
  double get touchProgress => _touchProgress;
  int get touchElapsedMs => _touchElapsedMs;
  String get formattedTime => _formattedTime;
  int get finalDurationMs => _finalDurationMs;
  List<dynamic> get leaderboard => _leaderboard;

  bool get isSimulatedMode => _bleService.isSimulatedMode;
  double get simulatedDistance => _bleService.simulatedDistance;

  GameProvider() {
    _initUser();
  }

  Future<void> _initUser() async {
    final user = await StorageService.getUser();
    if (user['name'] != null && user['name']!.isNotEmpty) {
      _playerName = user['name']!;
    }
    if (user['avatar'] != null && user['avatar']!.isNotEmpty) {
      _avatar = user['avatar']!;
    }
    notifyListeners();
  }

  void setPlayerDetails({required String name, required String avatar}) {
    _playerName = name;
    _avatar = avatar;
    notifyListeners();
  }

  void setSimulatedMode(bool value) {
    _bleService.setSimulatedMode(value);
    notifyListeners();
  }

  void updateSimulatedDistance(double dist) {
    _bleService.updateSimulatedDistance(dist);
    notifyListeners();
  }

  Future<void> joinEvent({
    required String name,
    required String code,
    required String avatarSymbol,
  }) async {
    _playerName = name;
    _eventCode = code;
    _avatar = avatarSymbol;
    _phase = GamePhase.waiting;
    notifyListeners();

    final result = await ApiService.joinEvent(
      name: name,
      eventCode: code,
      avatar: avatarSymbol,
    );

    if (result.containsKey('id')) {
      _playerId = result['id'];
    } else if (result.containsKey('playerId')) {
      _playerId = result['playerId'];
    }

    startLobbyMatchmakingPolling();
  }

  void startLobbyMatchmakingPolling() {
    _lobbyPollingTimer?.cancel();
    _lobbyPollingTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) async {
      if (_phase != GamePhase.waiting) {
        timer.cancel();
        return;
      }

      final matchData = await ApiService.getPlayerMatch(playerId: _playerId);
      if (matchData != null && matchData.containsKey('id')) {
        timer.cancel();
        String pId = matchData['id'] ?? 'PAIR_1';
        String r = matchData['role'] ?? 'LEFT';
        String partner = matchData['partnerName'] ?? 'Orientation Partner';
        String pAvatar = matchData['partnerAvatar'] ?? '🌟';
        String pPin = matchData['pin'] ?? '1042';

        assignPair(
          pairId: pId,
          partnerName: partner,
          partnerAvatar: pAvatar,
          imageHalf: r,
          pin: pPin,
        );
      }
    });
  }

  void assignPair({
    required String pairId,
    required String partnerName,
    required String partnerAvatar,
    required String imageHalf,
    String pin = '1042',
  }) {
    _lobbyPollingTimer?.cancel();
    _pairId = pairId;
    _partnerName = partnerName;
    _partnerAvatar = partnerAvatar;
    _imageHalf = imageHalf;
    _pairPin = pin;
    _phase = GamePhase.pairing;
    notifyListeners();
  }

  void startProximitySearch() {
    _phase = GamePhase.closer;
    _matchStopwatch.reset();
    _matchStopwatch.start();

    _matchTicker?.cancel();
    _matchTicker = Timer.periodic(const Duration(milliseconds: 50), (_) {
      final elapsed = _matchStopwatch.elapsed;
      final minutes = (elapsed.inMinutes % 60).toString().padLeft(2, '0');
      final seconds = (elapsed.inSeconds % 60).toString().padLeft(2, '0');
      final millis = ((elapsed.inMilliseconds % 1000) ~/ 10).toString().padLeft(2, '0');
      _formattedTime = '$minutes:$seconds.$millis';
      notifyListeners();
    });

    _bleService.startProximityMonitoring(
      targetPairId: _pairId,
      onUpdate: (rssi, level, distance) {
        _rssi = rssi;
        _proximityLevel = level;
        _estimatedDistance = distance;

        if (level == ProximityLevel.touch && _phase == GamePhase.closer) {
          _phase = GamePhase.touchMatch;
          startTouchCountdown();
        } else if (level != ProximityLevel.touch && _phase == GamePhase.touchMatch) {
          cancelTouchCountdown();
          _phase = GamePhase.closer;
        }

        notifyListeners();
      },
    );
  }

  void startTouchCountdown() {
    _touchTimer?.cancel();
    _touchElapsedMs = 0;
    _touchProgress = 0.0;

    _touchTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _touchElapsedMs += 100;
      _touchProgress = (_touchElapsedMs / touchRequiredDurationMs).clamp(0.0, 1.0);

      if (_touchElapsedMs >= touchRequiredDurationMs) {
        timer.cancel();
        // Touch signal confirmed! Require partner PIN verification in UI
      }
      notifyListeners();
    });
  }

  void cancelTouchCountdown() {
    _touchTimer?.cancel();
    _touchTimer = null;
    _touchProgress = 0.0;
    _touchElapsedMs = 0;
    notifyListeners();
  }

  Future<bool> completeMatch({String inputPin = ''}) async {
    final user = await StorageService.getUser();
    final pinToSend = inputPin.isNotEmpty ? inputPin : _pairPin;

    final res = await ApiService.completeMatch(
      pairId: _pairId,
      playerId: _playerId,
      pin: pinToSend,
      durationMs: _matchStopwatch.elapsedMilliseconds,
      userEmail: user['email'] ?? '',
    );

    if (res.containsKey('error') || res['status'] == 'FAILURE') {
      return false;
    }

    // Only known now: the real, unique-to-this-pair image halves generated by the backend.
    // Nothing before this point ever shows these — pre-match everyone just sees the same
    // generic locked placeholder, regardless of which pair they're in.
    if (res['leftHalfImage'] is String && (res['leftHalfImage'] as String).isNotEmpty) {
      _revealedLeftImage = res['leftHalfImage'];
    }
    if (res['rightHalfImage'] is String && (res['rightHalfImage'] as String).isNotEmpty) {
      _revealedRightImage = res['rightHalfImage'];
    }

    _bleService.stopMonitoring();
    _matchStopwatch.stop();
    _matchTicker?.cancel();
    _finalDurationMs = _matchStopwatch.elapsedMilliseconds;

    _phase = GamePhase.matchResult;
    notifyListeners();

    // Save match persistently using Hive / StorageService (only for Google Signed in users)
    await StorageService.saveMatch(
      partnerName: _partnerName,
      timeFormatted: _formattedTime,
      durationMs: _finalDurationMs,
      avatar: _partnerAvatar,
    );

    await fetchLeaderboard();
    return true;
  }

  Future<void> fetchLeaderboard() async {
    final list = await ApiService.getLeaderboard(eventId: _eventCode);
    _leaderboard = list;
    notifyListeners();
  }

  void resetGame() {
    _lobbyPollingTimer?.cancel();
    _touchTimer?.cancel();
    _matchTicker?.cancel();
    _matchStopwatch.stop();
    _matchStopwatch.reset();

    _pairId = '';
    _partnerName = 'Mystery Partner';
    _imageHalf = 'LEFT';
    _revealedLeftImage = null;
    _revealedRightImage = null;
    _proximityLevel = ProximityLevel.far;
    _touchProgress = 0.0;
    _touchElapsedMs = 0;
    _formattedTime = '00:00.00';
    _phase = GamePhase.home;
    notifyListeners();
  }
}