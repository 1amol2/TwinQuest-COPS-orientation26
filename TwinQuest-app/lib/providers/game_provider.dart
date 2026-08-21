import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/ble_service.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../services/websocket_service.dart';
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
  Timer? _lobbyRosterTimer;
  // Leaderboard data
  List<dynamic> _leaderboard = [];
  // Live lobby roster
  List<dynamic> _lobbyPlayers = [];
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
  List<dynamic> get lobbyPlayers => _lobbyPlayers;
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
    final user = await StorageService.getUser();

    final userId = user['id'] ?? '';

    if (userId.isEmpty) {
      throw Exception(
        'User ID not found. Please log in again.',
      );
    }

    _playerName = name;
    _eventCode = code;
    _avatar = avatarSymbol;
    _phase = GamePhase.waiting;
    notifyListeners();

    // 1. Create the player in the backend first.
    final result = await ApiService.joinEvent(
      userId: userId,
      name: name,
      eventCode: code,
      avatar: avatarSymbol,
    );

    // 2. Get the ACTUAL backend player ID.
    if (result.containsKey('id')) {
      _playerId = result['id'].toString();
    } else if (result.containsKey('playerId')) {
      _playerId = result['playerId'].toString();
    } else {
      throw Exception(
        'Backend did not return a player ID.',
      );
    }

    if (_playerId.isEmpty) {
      throw Exception(
        'Backend returned an empty player ID.',
      );
    }

    debugPrint(
      'JOIN EVENT: backend player ID = $_playerId',
    );

    // 3. NOW connect the STOMP WebSocket.
    WebSocketService().connect(
      wsUrl:
      'wss://twinquest-cops-orientation26-production-4aed.up.railway.app/ws',
      playerId: _playerId,
    );

    // 4. Start lobby matchmaking polling.
    startLobbyMatchmakingPolling();

// 5. Start live lobby roster polling.
    startLobbyRosterPolling();

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
        final String pPin = (matchData['pin'] ?? '').toString();

        if (pPin.length != 4) {
          debugPrint('INVALID/MISSING PAIR PIN FROM BACKEND: $matchData');
          return;
        }

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
  void startLobbyRosterPolling() {
    _lobbyRosterTimer?.cancel();

    Future<void> refreshRoster() async {
      try {
        final players = await ApiService.getLobbyPlayers(
          eventId: _eventCode,
        );

        _lobbyPlayers = players;
        notifyListeners();

        debugPrint(
          'LOBBY ROSTER: ${_lobbyPlayers.length} players',
        );
      } catch (e) {
        debugPrint(
          'LOBBY ROSTER ERROR: $e',
        );
      }
    }

    // Get the roster immediately.
    refreshRoster();

    // Then keep it updated.
    _lobbyRosterTimer = Timer.periodic(
      const Duration(seconds: 1),
          (_) {
        if (_phase != GamePhase.waiting) {
          _lobbyRosterTimer?.cancel();
          return;
        }

        refreshRoster();
      },
    );
  }
  void assignPair({
    required String pairId,
    required String partnerName,
    required String partnerAvatar,
    required String imageHalf,
    required String pin,
  }) {
    _lobbyPollingTimer?.cancel();
    _lobbyRosterTimer?.cancel();

    _pairId = pairId;
    _partnerName = partnerName;
    _partnerAvatar = partnerAvatar;
    _imageHalf = imageHalf;
    _pairPin = pin;
    _phase = GamePhase.pairing;

    notifyListeners();
  }

  Future<void> startProximitySearch() async {
    _phase = GamePhase.closer;

    _matchStopwatch.reset();
    _matchStopwatch.start();

    _matchTicker?.cancel();

    _matchTicker = Timer.periodic(
      const Duration(milliseconds: 50),
          (_) {
        final elapsed = _matchStopwatch.elapsed;

        final minutes =
        (elapsed.inMinutes % 60).toString().padLeft(2, '0');

        final seconds =
        (elapsed.inSeconds % 60).toString().padLeft(2, '0');

        final millis =
        ((elapsed.inMilliseconds % 1000) ~/ 10)
            .toString()
            .padLeft(2, '0');

        _formattedTime = '$minutes:$seconds.$millis';

        notifyListeners();
      },
    );

    await _bleService.startProximityMonitoring(
      targetPairId: _pairId,
      playerId: _playerId,
      onUpdate: (rssi, level, distance) {
        debugPrint(
          'GAME PROVIDER BLE UPDATE: '
              'rssi=$rssi '
              'level=$level '
              'distance=$distance',
        );

        _rssi = rssi;
        _proximityLevel = level;
        _estimatedDistance = distance;

        if (level == ProximityLevel.touch &&
            _phase == GamePhase.closer) {
          _phase = GamePhase.touchMatch;
          startTouchCountdown();
        } else if (level != ProximityLevel.touch &&
            _phase == GamePhase.touchMatch) {
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

        debugPrint(
          'TOUCH CONFIRMED: pair=$_pairId',
        );

        markPairAsFound();
      }
      notifyListeners();
    });
  }
  Future<void> markPairAsFound() async {
    if (_pairId.isEmpty) {
      debugPrint('PAIR FOUND: pairId is empty');
      return;
    }

    try {
      debugPrint(
        'PAIR FOUND: sending FOUND for pair=$_pairId',
      );

      final result = await ApiService.markPairFound(
        pairId: _pairId,
      );

      debugPrint(
        'PAIR FOUND RESPONSE: $result',
      );
    } catch (e) {
      debugPrint(
        'PAIR FOUND ERROR: $e',
      );
    }
  }
  void cancelTouchCountdown() {
    _touchTimer?.cancel();
    _touchTimer = null;
    _touchProgress = 0.0;
    _touchElapsedMs = 0;
    notifyListeners();
  }

  Future<bool> completeMatch({
    String inputPin = '',
  }) async {

    final user = await StorageService.getUser();

    final pinToSend =
    inputPin.isNotEmpty ? inputPin : _pairPin;

    debugPrint(
      'PIN VERIFY DEBUG: '
          'pairId=$_pairId '
          'playerId=$_playerId '
          'enteredPin=$pinToSend',
    );

    try {

      final res = await ApiService.completeMatch(
        pairId: _pairId,
        playerId: _playerId,
        pin: pinToSend,
        durationMs: _matchStopwatch.elapsedMilliseconds,
        userEmail: user['email'] ?? '',
      );

      debugPrint(
        'PIN VERIFY RESPONSE: $res',
      );

      /*
     * Backend rejected the PIN/request.
     */
      if (res.containsKey('error') ||
          res['status'] == 'FAILURE') {

        debugPrint(
          'PIN VERIFY FAILED: $res',
        );

        return false;
      }

      /*
     * THIS player verified successfully,
     * but the partner hasn't verified yet.
     */
      if (res['status'] == 'CONFIRMED') {

        debugPrint(
          'PIN VERIFIED: waiting for partner verification',
        );

        /*
       * Important:
       * Return false so TouchMatchScreen does NOT
       * navigate to the result screen.
       *
       * But we need to distinguish this from
       * an actually invalid PIN in the UI.
       */
        return false;
      }

      /*
     * BOTH players have verified.
     */
      if (res['status'] == 'COMPLETED') {

        debugPrint(
          'BOTH PLAYERS VERIFIED: match completed',
        );

        /*
       * Existing result/image handling.
       */
        _bleService.stopMonitoring();

        _matchStopwatch.stop();

        _matchTicker?.cancel();

        _finalDurationMs =
            _matchStopwatch.elapsedMilliseconds;

        _phase =
            GamePhase.matchResult;

        notifyListeners();

        await StorageService.saveMatch(
          partnerName: _partnerName,
          timeFormatted: _formattedTime,
          durationMs: _finalDurationMs,
          avatar: _partnerAvatar,
        );

        await fetchLeaderboard();

        return true;
      }

      debugPrint(
        'PIN VERIFY: unexpected response status '
            '${res['status']}',
      );

      return false;

    } catch (e) {

      debugPrint(
        'PIN VERIFY ERROR: $e',
      );

      return false;
    }
  }

  Future<void> fetchLeaderboard() async {
    final list = await ApiService.getLeaderboard(
      eventCode: _eventCode,
    );

    _leaderboard = list;
    notifyListeners();
  }
  Future<void> returnToPairSearch() async {
    // Stop BLE proximity monitoring.
    _bleService.stopMonitoring();

    // Stop match timer.
    _matchTicker?.cancel();
    _matchStopwatch.stop();
    _matchStopwatch.reset();

    // Cancel touch countdown.
    _touchTimer?.cancel();
    _touchTimer = null;
    _touchElapsedMs = 0;
    _touchProgress = 0.0;

    // Clear current pair information.
    _pairId = '';
    _partnerName = 'Mystery Partner';
    _partnerAvatar = '🌟';
    _imageHalf = 'LEFT';
    _pairPin = '1042';

    // Reset proximity state.
    _rssi = -80;
    _proximityLevel = ProximityLevel.far;
    _estimatedDistance = 8.0;

    _formattedTime = '00:00.00';

    // Go back to lobby/waiting state.
    _phase = GamePhase.waiting;

    notifyListeners();

    // Start looking for a new pair.
    startLobbyMatchmakingPolling();

    // Resume live lobby roster.
    startLobbyRosterPolling();
  }
  void resetGame() {
    WebSocketService().leave();

    _lobbyPollingTimer?.cancel();
    _lobbyRosterTimer?.cancel();

    _touchTimer?.cancel();
    _matchTicker?.cancel();
    _matchStopwatch.stop();
    _matchStopwatch.reset();

    _pairId = '';
    _lobbyPlayers = [];
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