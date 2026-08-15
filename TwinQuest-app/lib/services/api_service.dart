import 'dart:convert';
import 'package:http/http.dart' as http;

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  @override
  String toString() => message;
}

class ApiService {
  static String baseUrl = 'http://localhost:8080/api';
  static String? lastError;

  static void setBaseUrl(String url) {
    String formatted = url.trim();
    if (!formatted.startsWith('http://') && !formatted.startsWith('https://')) {
      formatted = 'http://$formatted';
    }
    if (formatted.endsWith('/')) {
      formatted = formatted.substring(0, formatted.length - 1);
    }
    if (!formatted.endsWith('/api')) {
      formatted = '$formatted/api';
    }
    baseUrl = formatted;
  }

  static Future<bool> testConnection() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/events/ORIENT26/players')).timeout(const Duration(seconds: 4));
      lastError = null;
      return response.statusCode == 200;
    } catch (e) {
      lastError = 'Cannot reach backend at $baseUrl: $e';
      return false;
    }
  }

  /// Google Authentication Endpoint
  static Future<Map<String, dynamic>> authenticateGoogle({
    required String email,
    required String name,
    required String avatar,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'name': name,
          'avatar': avatar,
          'authType': 'GOOGLE',
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (_) {}
    return {
      'token': 'PQ_TOKEN_$email:${DateTime.now().millisecondsSinceEpoch}:OFFLINE',
      'user': {
        'email': email,
        'name': name,
        'avatar': avatar,
        'authType': 'GOOGLE',
      },
    };
  }

  /// Guest Authentication Endpoint
  static Future<Map<String, dynamic>> authenticateGuest({
    required String name,
    required String avatar,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/guest'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': 'guest@pairquest.app',
          'name': name,
          'avatar': avatar,
          'authType': 'GUEST',
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (_) {}
    return {
      'token': 'PQ_TOKEN_guest@pairquest.app:${DateTime.now().millisecondsSinceEpoch}:GUEST',
      'user': {
        'email': 'guest@pairquest.app',
        'name': name,
        'avatar': avatar,
        'authType': 'GUEST',
      },
    };
  }

  /// Fetch User Profile & Stats from Backend
  static Future<Map<String, dynamic>?> getUserProfile({required String email}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$email/profile'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (_) {}
    return null;
  }

  /// Fetch User Saved Match History from Backend Database
  static Future<List<dynamic>> getUserMatches({required String email}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$email/matches'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (_) {}
    return [];
  }

  /// Create a new orientation event
  static Future<Map<String, dynamic>> createEvent({required String title}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/events/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'title': title}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }
    } catch (_) {}
    return {
      'id': 'EVT_MOCK_1',
      'code': 'ORIENT26',
      'title': title,
      'status': 'WAITING',
    };
  }

  /// Join an existing orientation event
  static Future<Map<String, dynamic>> joinEvent({
    required String name,
    required String eventCode,
    required String avatar,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/events/join'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'eventCode': eventCode,
          'avatar': avatar,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }
    } catch (_) {}
    return {
      'playerId': 'PLR_${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      'name': name,
      'eventCode': eventCode,
      'avatar': avatar,
      'status': 'WAITING',
    };
  }

  /// Fetch all volunteers currently joined in lobby
  static Future<List<dynamic>> getLobbyPlayers({required String eventId}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/events/$eventId/players'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (_) {}
    return [];
  }

  /// Reset orientation event lobby
  static Future<void> resetEvent({required String eventId, String token = ''}) async {
    try {
      final headers = <String, String>{};
      if (token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
      await http.post(
        Uri.parse('$baseUrl/events/$eventId/reset'),
        headers: headers,
      );
    } catch (_) {}
  }

  /// Trigger random matchmaking for N volunteers
  static Future<Map<String, dynamic>> startMatchmaking({required String eventId}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/events/$eventId/start'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (_) {}
    return {'status': 'SUCCESS'};
  }

  /// Check pair match assignment
  static Future<Map<String, dynamic>?> getPlayerMatch({required String playerId}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/matches/player/$playerId'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (_) {}
    return null;
  }

  /// Complete match and submit timer to database with userEmail link and PIN verification
  static Future<Map<String, dynamic>> completeMatch({
    required String pairId,
    required String playerId,
    String pin = '',
    required int durationMs,
    String userEmail = '',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/matches/complete'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'pairId': pairId,
          'playerId': playerId,
          'pin': pin,
          'durationMs': durationMs,
          'userEmail': userEmail,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (_) {}
    return {'status': 'COMPLETED', 'pairId': pairId, 'durationMs': durationMs};
  }

  /// Get live leaderboard entries
  static Future<List<dynamic>> getLeaderboard({required String eventId}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/leaderboard/$eventId'),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (_) {}
    return [];
  }
}
