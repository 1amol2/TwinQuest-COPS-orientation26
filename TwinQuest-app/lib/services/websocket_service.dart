import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class WebSocketService {
  static final WebSocketService _instance =
  WebSocketService._internal();

  factory WebSocketService() => _instance;

  WebSocketService._internal();

  StompClient? _client;

  String? _playerId;

  bool get isConnected => _client?.connected ?? false;

  // Callback used to notify GameProvider about backend events.
  Function(Map<String, dynamic>)? _onPlayerEvent;

  void connect({
    required String wsUrl,
    required String playerId,
    Function(Map<String, dynamic>)? onPlayerEvent,
  }) {
    debugPrint('WS: connecting...');
    debugPrint('WS URL: $wsUrl');
    debugPrint('WS PLAYER ID: $playerId');

    disconnect();

    _playerId = playerId;
    _onPlayerEvent = onPlayerEvent;

    _client = StompClient(
      config: StompConfig(
        url: wsUrl,

        reconnectDelay: Duration.zero,

        onConnect: (StompFrame frame) {
          debugPrint('WS: STOMP CONNECTED');
          debugPrint('WS: registering player $_playerId');

          _subscribeToPlayer();

          _client!.send(
            destination: '/app/pairing/join',
            body: jsonEncode({
              'playerId': _playerId,
            }),
            headers: {
              'content-type': 'application/json',
            },
          );

          debugPrint('WS: sent /app/pairing/join');
        },

        onDisconnect: (StompFrame frame) {
          debugPrint('WS: STOMP DISCONNECTED');
        },

        onWebSocketDone: () {
          debugPrint('WS: underlying WebSocket closed');
        },

        onWebSocketError: (dynamic error) {
          debugPrint('WS: WebSocket ERROR: $error');
        },

        onStompError: (StompFrame frame) {
          debugPrint(
            'WS: STOMP ERROR: ${frame.body}',
          );
        },

        onDebugMessage: (message) {
          debugPrint('WS DEBUG: $message');
        },
      ),
    );

    _client!.activate();
  }

  void _subscribeToPlayer() {
    final playerId = _playerId;

    if (playerId == null || playerId.isEmpty) {
      debugPrint(
        'WS: Cannot subscribe - playerId is empty',
      );
      return;
    }

    _client!.subscribe(
      destination: '/topic/player/$playerId',
      callback: (StompFrame frame) {
        debugPrint('========================================');
        debugPrint('WS PLAYER EVENT RECEIVED');
        debugPrint('Player ID: $playerId');
        debugPrint('Raw body: ${frame.body}');
        debugPrint('========================================');

        if (frame.body == null || frame.body!.isEmpty) {
          debugPrint('WS: Empty event body');
          return;
        }

        try {
          final Map<String, dynamic> event =
          jsonDecode(frame.body!);

          debugPrint('WS EVENT TYPE: ${event['type']}');
          debugPrint('WS EVENT STATUS: ${event['status']}');
          debugPrint('WS EVENT PAIR ID: ${event['pairId']}');

          // Forward the event to GameProvider.
          _onPlayerEvent?.call(event);

        } catch (e) {
          debugPrint(
            'WS: Failed to parse player event: $e',
          );
        }
      },
    );

    debugPrint(
      'WS: subscribed to /topic/player/$playerId',
    );
  }

  void sendMessage({
    required String destination,
    required Map<String, dynamic> message,
  }) {
    if (_client == null || !_client!.connected) {
      debugPrint(
        'WS: Cannot send - not connected',
      );
      return;
    }

    _client!.send(
      destination: destination,
      body: jsonEncode(message),
      headers: {
        'content-type': 'application/json',
      },
    );
  }

  void leave() {
    final playerId = _playerId;

    if (_client != null &&
        _client!.connected &&
        playerId != null &&
        playerId.isNotEmpty) {
      debugPrint(
        'WS: sending pairing leave for $playerId',
      );

      _client!.send(
        destination: '/app/pairing/leave',
        body: jsonEncode({
          'playerId': playerId,
        }),
        headers: {
          'content-type': 'application/json',
        },
      );
    }

    disconnect();
  }

  void disconnect() {
    if (_client != null) {
      debugPrint(
        'WS: deactivating STOMP connection',
      );

      _client!.deactivate();
      _client = null;
    }

    _playerId = null;
    _onPlayerEvent = null;
  }
}