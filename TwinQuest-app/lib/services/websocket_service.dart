import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();

  factory WebSocketService() => _instance;

  WebSocketService._internal();

  StompClient? _client;

  String? _playerId;

  bool get isConnected => _client?.connected ?? false;

  /// Connect to the Spring Boot STOMP WebSocket.
  ///
  /// wsUrl should be something like:
  /// ws://localhost:8080/ws
  /// or
  /// wss://your-railway-domain/ws
  void connect({
    required String wsUrl,
    required String playerId,
  }) {
    debugPrint('WS: connecting...');
    debugPrint('WS URL: $wsUrl');
    debugPrint('WS PLAYER ID: $playerId');

    disconnect();

    _playerId = playerId;

    _client = StompClient(
      config: StompConfig(
        url: wsUrl,

        // Keep reconnect disabled for now.
        // We don't want an old player session accidentally
        // reconnecting after the app is closed.
        reconnectDelay: Duration.zero,

        onConnect: (StompFrame frame) {
          debugPrint('WS: STOMP CONNECTED');
          debugPrint('WS: registering player $_playerId');

          _subscribeToPlayer();

          // Register this player's actual STOMP session
          // with the Spring backend.
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
          debugPrint('WS: STOMP ERROR: ${frame.body}');
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
      debugPrint('WS: Cannot subscribe - playerId is empty');
      return;
    }

    _client!.subscribe(
      destination: '/topic/player/$playerId',
      callback: (StompFrame frame) {
        debugPrint(
          'WS PLAYER EVENT: ${frame.body}',
        );
      },
    );

    debugPrint(
      'WS: subscribed to /topic/player/$playerId',
    );
  }

  /// Sends a STOMP message to the backend.
  void sendMessage({
    required String destination,
    required Map<String, dynamic> message,
  }) {
    if (_client == null || !_client!.connected) {
      debugPrint('WS: Cannot send - not connected');
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

  /// Explicitly tell backend that this player is leaving,
  /// then close the STOMP connection.
  void leave() {
    final playerId = _playerId;

    if (_client != null &&
        _client!.connected &&
        playerId != null &&
        playerId.isNotEmpty) {
      debugPrint('WS: sending pairing leave for $playerId');

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

  /// Close the STOMP connection.
  ///
  /// The backend's SessionDisconnectEvent should also
  /// perform cleanup when the connection actually closes.
  void disconnect() {
    if (_client != null) {
      debugPrint('WS: deactivating STOMP connection');
      _client!.deactivate();
      _client = null;
    }

    _playerId = null;
  }
}