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
enum MatchVerificationResult {
  invalid,
  confirmed,
  completed,
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
  Timer? _touchExitTimer;

  static const Duration _touchExitGracePeriod =
  Duration(milliseconds: 1200);

  static const Duration _touchConfirmDuration =
  Duration(milliseconds: 2500);

  final int touchRequiredDurationMs = 2500;

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

    debugPrint('========================================');
    debugPrint('PAIR ASSIGNED');
    debugPrint('Pair ID: $_pairId');
    debugPrint('Player ID: $_playerId');
    debugPrint('Partner: $_partnerName');
    debugPrint('Role/Image half: $_imageHalf');
    debugPrint('PAIR PIN RECEIVED: $_pairPin');
    debugPrint('========================================');

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
        _estimatedDistance = distance;

        // ------------------------------------------------------------
        // TOUCH DETECTED
        // ------------------------------------------------------------
        if (level == ProximityLevel.touch) {
          // The partner is still touching/very close.
          // Cancel any pending exit caused by a noisy RSSI reading.
          _touchExitTimer?.cancel();
          _touchExitTimer = null;

          _proximityLevel = ProximityLevel.touch;

          if (_phase == GamePhase.closer) {
            _phase = GamePhase.touchMatch;

            debugPrint('========================================');
            debugPrint('BLE PARTNER FOUND - TOUCH ZONE ENTERED');
            debugPrint('Pair ID: $_pairId');
            debugPrint('Player ID: $_playerId');
            debugPrint('RSSI: $rssi');
            debugPrint(
              'Distance: ${distance.toStringAsFixed(2)}m',
            );
            debugPrint('SETTING PAIR STATUS TO FOUND');
            debugPrint('========================================');

            markPairAsFound();

            startTouchCountdown();
          }
          notifyListeners();
          return;
        }

        // ------------------------------------------------------------
        // WE ARE ALREADY IN TOUCH BUT RSSI TEMPORARILY DROPPED
        // ------------------------------------------------------------
        if (_phase == GamePhase.touchMatch) {
          // Keep the UI in TOUCH during the grace period.
          _proximityLevel = ProximityLevel.touch;

          // Don't create multiple timers.
          if (_touchExitTimer?.isActive ?? false) {
            notifyListeners();
            return;
          }

          debugPrint(
            'TOUCH RSSI DROPPED: starting ${_touchExitGracePeriod.inMilliseconds}ms grace period',
          );

          _touchExitTimer = Timer(
            _touchExitGracePeriod,
                () {
              _touchExitTimer = null;

              // If we haven't received another TOUCH reading during
              // the grace period, the phones have genuinely moved apart.
              if (_phase == GamePhase.touchMatch) {
                debugPrint(
                  'TOUCH LOST: returning to closer state',
                );

                cancelTouchCountdown();

                _proximityLevel = level;
                _phase = GamePhase.closer;

                notifyListeners();
              }
            },
          );

          notifyListeners();
          return;
        }

        // ------------------------------------------------------------
        // NORMAL CLOSER STATE
        // ------------------------------------------------------------
        _proximityLevel = level;

        notifyListeners();
      },
    );
  }

  void startTouchCountdown() {
    _touchTimer?.cancel();

    _touchElapsedMs = 0;
    _touchProgress = 0.0;

    debugPrint('========================================');
    debugPrint('TOUCH COUNTDOWN STARTED');
    debugPrint('Pair ID: $_pairId');
    debugPrint('Player ID: $_playerId');
    debugPrint('Required duration: $touchRequiredDurationMs ms');
    debugPrint('========================================');

    _touchTimer = Timer.periodic(
      const Duration(milliseconds: 100),
          (timer) async {
        _touchElapsedMs += 100;

        _touchProgress =
            (_touchElapsedMs / touchRequiredDurationMs)
                .clamp(0.0, 1.0);

        // Useful progress logs without flooding Logcat.
        if (_touchElapsedMs % 500 == 0) {
          debugPrint(
            'TOUCH COUNTDOWN: '
                '${_touchElapsedMs}ms / '
                '$touchRequiredDurationMs ms '
                '(${(_touchProgress * 100).toStringAsFixed(0)}%)',
          );
        }

        if (_touchElapsedMs >= touchRequiredDurationMs) {
          timer.cancel();

          debugPrint('========================================');
          debugPrint('TOUCH CONFIRMED');
          debugPrint('Pair ID: $_pairId');
          debugPrint('Player ID: $_playerId');
          debugPrint('Touch duration: $_touchElapsedMs ms');
          debugPrint(
            'Required duration: $touchRequiredDurationMs ms',
          );
          debugPrint('Current phase: $_phase');
          debugPrint('========================================');

          await markPairAsFound();
        }

        notifyListeners();
      },
    );
  }
  Future<void> markPairAsFound() async {
    if (_pairId.isEmpty) {
      debugPrint('========================================');
      debugPrint('PAIR FOUND ERROR');
      debugPrint('pairId is EMPTY');
      debugPrint('Player ID: $_playerId');
      debugPrint('========================================');
      return;
    }

    debugPrint('========================================');
    debugPrint('PAIR FOUND REQUEST');
    debugPrint('Pair ID: $_pairId');
    debugPrint('Player ID: $_playerId');
    debugPrint('Sending FOUND to backend...');
    debugPrint('========================================');

    try {
      final result = await ApiService.markPairFound(
        pairId: _pairId,
      );

      debugPrint('========================================');
      debugPrint('PAIR FOUND RESPONSE');
      debugPrint('Pair ID: $_pairId');
      debugPrint('Player ID: $_playerId');
      debugPrint('Response: $result');
      debugPrint('========================================');
    } catch (e, stackTrace) {
      debugPrint('========================================');
      debugPrint('PAIR FOUND ERROR');
      debugPrint('Pair ID: $_pairId');
      debugPrint('Player ID: $_playerId');
      debugPrint('Error: $e');
      debugPrint('StackTrace: $stackTrace');
      debugPrint('========================================');
    }
  }
  void cancelTouchCountdown() {
    _touchTimer?.cancel();
    _touchTimer = null;
    _touchProgress = 0.0;
    _touchElapsedMs = 0;
    notifyListeners();
  }

  Future<MatchVerificationResult> completeMatch({
    String inputPin = '',
  }) async {
    final user = await StorageService.getUser();

    final pinToSend =
    inputPin.isNotEmpty ? inputPin.trim() : _pairPin.trim();

    debugPrint('========================================');
    debugPrint('PIN VERIFY CLIENT REQUEST');
    debugPrint('Pair ID       : $_pairId');
    debugPrint('Player ID     : $_playerId');
    debugPrint('Own PIN       : $_pairPin');
    debugPrint('Entered PIN   : $pinToSend');
    debugPrint('Partner Name  : $_partnerName');
    debugPrint('Player Email  : ${user['email']}');
    debugPrint('========================================');

    try {
      final res = await ApiService.completeMatch(
        pairId: _pairId,
        playerId: _playerId,
        pin: pinToSend,
        durationMs: _matchStopwatch.elapsedMilliseconds,
        userEmail: user['email'] ?? '',
      );

      final status = res['status']?.toString();

      debugPrint('========================================');
      debugPrint('PIN VERIFY CLIENT RESPONSE');
      debugPrint('Response status: $status');
      debugPrint('Response error : ${res['error']}');
      debugPrint('========================================');

      // ============================================================
      // COMPLETED
      // ============================================================
      if (status == 'COMPLETED') {
        debugPrint('========================================');
        debugPrint('PIN VERIFY RESULT: COMPLETED');
        debugPrint('BACKEND CONFIRMED BOTH PLAYERS');
        debugPrint('Pair ID: $_pairId');
        debugPrint('Player ID: $_playerId');
        debugPrint('========================================');

        // IMPORTANT:
        // From this point onward, NOTHING should be allowed
        // to change the result to INVALID.

        try {
          debugPrint('COMPLETED STEP 1: stopping BLE');

          await _bleService.stopMonitoring();

          debugPrint('COMPLETED STEP 1: BLE stopped');
        } catch (e, stackTrace) {
          debugPrint('BLE STOP ERROR: $e');
          debugPrint('$stackTrace');

          // Do NOT fail the match because BLE cleanup failed.
        }

        try {
          debugPrint('COMPLETED STEP 2: stopping stopwatch');

          _matchStopwatch.stop();
          _matchTicker?.cancel();

          _finalDurationMs =
              _matchStopwatch.elapsedMilliseconds;

          debugPrint(
            'Final duration: $_finalDurationMs ms',
          );
        } catch (e, stackTrace) {
          debugPrint('STOPWATCH ERROR: $e');
          debugPrint('$stackTrace');
        }

        _phase = GamePhase.matchResult;

        notifyListeners();

        debugPrint(
          'COMPLETED STEP 3: phase set to matchResult',
        );

        try {
          debugPrint('COMPLETED STEP 4: saving match');

          await StorageService.saveMatch(
            partnerName: _partnerName,
            timeFormatted: _formattedTime,
            durationMs: _finalDurationMs,
            avatar: _partnerAvatar,
          );

          debugPrint('COMPLETED STEP 4: match saved');
        } catch (e, stackTrace) {
          debugPrint('SAVE MATCH ERROR: $e');
          debugPrint('$stackTrace');

          // Do NOT fail the match.
        }

        try {
          debugPrint('COMPLETED STEP 5: fetching leaderboard');

          await fetchLeaderboard();

          debugPrint('COMPLETED STEP 5: leaderboard fetched');
        } catch (e, stackTrace) {
          debugPrint('LEADERBOARD ERROR: $e');
          debugPrint('$stackTrace');

          // Do NOT fail the match.
        }

        debugPrint('========================================');
        debugPrint('RETURNING COMPLETED TO UI');
        debugPrint('========================================');

        return MatchVerificationResult.completed;
      }

      // ============================================================
      // CONFIRMED
      // ============================================================
      if (status == 'CONFIRMED') {
        debugPrint('========================================');
        debugPrint('PIN VERIFY RESULT: CONFIRMED');
        debugPrint('Waiting for partner verification');
        debugPrint('========================================');

        return MatchVerificationResult.confirmed;
      }

      // ============================================================
      // FAILURE
      // ============================================================
      if (res.containsKey('error') ||
          status == 'FAILURE') {
        debugPrint('========================================');
        debugPrint('PIN VERIFY RESULT: INVALID');
        debugPrint('Backend response: $res');
        debugPrint('========================================');

        return MatchVerificationResult.invalid;
      }

      // ============================================================
      // UNKNOWN
      // ============================================================
      debugPrint('========================================');
      debugPrint('PIN VERIFY RESULT: UNKNOWN');
      debugPrint('Status: $status');
      debugPrint('Response: $res');
      debugPrint('========================================');

      return MatchVerificationResult.invalid;

    } catch (e, stackTrace) {
      debugPrint('========================================');
      debugPrint('PIN VERIFY CLIENT ERROR');
      debugPrint('Error: $e');
      debugPrint('StackTrace: $stackTrace');
      debugPrint('========================================');

      return MatchVerificationResult.invalid;
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