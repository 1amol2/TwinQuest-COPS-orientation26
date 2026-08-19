import 'api_service.dart';

class ServerConfig {
  static const String baseUrl =
      'https://twinquest-cops-orientation26-production-4aed.up.railway.app/api';

  static const String wsUrl =
      'wss://twinquest-cops-orientation26-production-4aed.up.railway.app/ws';

  static void updateHost(String newHost, {int newPort = 8080}) {
    ApiService.setBaseUrl(baseUrl);
  }
}