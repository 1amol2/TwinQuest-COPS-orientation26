import 'package:flutter/foundation.dart';
import 'api_service.dart';

class ServerConfig {
  static String hostIp = 'localhost';
  static int port = 8080;

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://$hostIp:$port/api';
    }
    return 'http://$hostIp:$port/api';
  }

  static String get wsUrl {
    return 'ws://$hostIp:$port/ws/game/websocket';
  }

  static void updateHost(String newHost, {int newPort = 8080}) {
    hostIp = newHost.trim().isEmpty ? 'localhost' : newHost.trim();
    port = newPort;
    ApiService.setBaseUrl(baseUrl);
  }
}
