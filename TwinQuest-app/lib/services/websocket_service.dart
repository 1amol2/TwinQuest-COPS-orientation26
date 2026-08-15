import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  final StreamController<Map<String, dynamic>> _eventController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get events => _eventController.stream;

  void connect(String wsUrl) {
    try {
      disconnect();
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _subscription = _channel?.stream.listen(
        (data) {
          try {
            final Map<String, dynamic> event = jsonDecode(data);
            _eventController.add(event);
          } catch (e) {
            debugPrint('WebSocket parse error: $e');
          }
        },
        onError: (err) => debugPrint('WebSocket error: $err'),
        onDone: () => debugPrint('WebSocket connection closed'),
      );
    } catch (e) {
      debugPrint('WebSocket connect error: $e');
    }
  }

  void sendMessage(Map<String, dynamic> message) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode(message));
    }
  }

  void disconnect() {
    _subscription?.cancel();
    _subscription = null;
    _channel?.sink.close();
    _channel = null;
  }
}
