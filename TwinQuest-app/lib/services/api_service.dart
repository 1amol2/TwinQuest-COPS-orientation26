import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
class NetworkException implements Exception {
  final String message;

  NetworkException(this.message);

  @override
  String toString() => message;
}

class ApiService {
  static String baseUrl =
      'https://twinquest-cops-orientation26-production-4aed.up.railway.app/api';

  static String? lastError;

  static void setBaseUrl(String url) {
    String formatted = url.trim();

    if (!formatted.startsWith('http://') &&
        !formatted.startsWith('https://')) {
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
      final response = await http
          .get(
        Uri.parse('$baseUrl/events/ORIENT26/players'),
      )
          .timeout(const Duration(seconds: 5));

      lastError = null;

      return response.statusCode >= 200 &&
          response.statusCode < 300;
    } catch (e) {
      lastError = 'Cannot reach backend at $baseUrl: $e';
      return false;
    }
  }

  static Future<Map<String, dynamic>> authenticateGuest({
    required String name,
    required String avatar,
  }) async {
    final guestId = await getGuestId();
    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/auth/guest'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'guestId': guestId,
          'name': name,
          'avatar': avatar,
        }),
      )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        lastError = null;
        return jsonDecode(response.body);
      }

      throw NetworkException(
        'Guest authentication failed '
            '(${response.statusCode}): ${response.body}',
      );
    } catch (e) {
      if (e is NetworkException) {
        lastError = e.message;
        rethrow;
      }

      lastError = 'Guest authentication request failed: $e';

      throw NetworkException(
        'Unable to connect to backend: $e',
      );
    }
  }

  /// Create a new orientation event.
  static Future<Map<String, dynamic>> createEvent({
    required String title,
  }) async {
    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/events/create'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'title': title,
        }),
      )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        lastError = null;
        return jsonDecode(response.body);
      }

      throw NetworkException(
        'Event creation failed '
            '(${response.statusCode}): ${response.body}',
      );
    } catch (e) {
      if (e is NetworkException) {
        lastError = e.message;
        rethrow;
      }

      lastError = 'Event creation request failed: $e';

      throw NetworkException(
        'Unable to connect to backend: $e',
      );
    }
  }
  /// Create or fetch the fixed orientation event.
  static Future<Map<String, dynamic>> createOrientationEvent() async {
    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/events/orientation'),
        headers: {
          'Content-Type': 'application/json',
        },
      )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        lastError = null;
        return jsonDecode(response.body);
      }

      throw NetworkException(
        'Orientation event creation failed '
            '(${response.statusCode}): ${response.body}',
      );
    } catch (e) {
      if (e is NetworkException) {
        lastError = e.message;
        rethrow;
      }

      lastError = 'Orientation event request failed: $e';

      throw NetworkException(
        'Unable to connect to backend: $e',
      );
    }
  }
  /// Join an existing orientation event.
  static Future<Map<String, dynamic>> joinEvent({
    required String userId,
    required String name,
    required String eventCode,
    required String avatar,
  }) async {
    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/events/join'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'userId': userId,
          'name': name,
          'eventCode': eventCode,
          'avatar': avatar,
        }),
      )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        lastError = null;
        return jsonDecode(response.body);
      }

      throw NetworkException(
        'Joining event failed '
            '(${response.statusCode}): ${response.body}',
      );
    } catch (e) {
      if (e is NetworkException) {
        lastError = e.message;
        rethrow;
      }

      lastError = 'Join event request failed: $e';

      throw NetworkException(
        'Unable to connect to backend: $e',
      );
    }
  }

  /// Fetch all players currently joined in lobby.
  static Future<List<dynamic>> getLobbyPlayers({
    required String eventId,
  }) async {
    try {
      final response = await http
          .get(
        Uri.parse('$baseUrl/events/$eventId/players'),
      )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        lastError = null;
        return jsonDecode(response.body);
      }

      throw NetworkException(
        'Failed to fetch lobby '
            '(${response.statusCode}): ${response.body}',
      );
    } catch (e) {
      if (e is NetworkException) {
        lastError = e.message;
        rethrow;
      }

      lastError = 'Lobby request failed: $e';

      throw NetworkException(
        'Unable to connect to backend: $e',
      );
    }
  }

  /// Reset orientation event lobby.
  static Future<void> resetEvent({
    required String eventId,
    String token = '',
  }) async {
    try {
      final headers = <String, String>{};

      if (token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http
          .post(
        Uri.parse('$baseUrl/events/$eventId/reset'),
        headers: headers,
      )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        lastError = null;
        return;
      }

      throw NetworkException(
        'Event reset failed '
            '(${response.statusCode}): ${response.body}',
      );
    } catch (e) {
      if (e is NetworkException) {
        lastError = e.message;
        rethrow;
      }

      lastError = 'Event reset request failed: $e';

      throw NetworkException(
        'Unable to connect to backend: $e',
      );
    }
  }

  /// Start matchmaking for an event.
  static Future<Map<String, dynamic>> startMatchmaking({
    required String eventId,
  }) async {
    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/events/$eventId/start'),
        headers: {
          'Content-Type': 'application/json',
        },
      )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        lastError = null;
        return jsonDecode(response.body);
      }

      throw NetworkException(
        'Matchmaking failed '
            '(${response.statusCode}): ${response.body}',
      );
    } catch (e) {
      if (e is NetworkException) {
        lastError = e.message;
        rethrow;
      }

      lastError = 'Matchmaking request failed: $e';

      throw NetworkException(
        'Unable to connect to backend: $e',
      );
    }
  }

  /// Get the pair assigned to a player.
  static Future<Map<String, dynamic>> getPlayerMatch({
    required String playerId,
  }) async {
    try {
      final response = await http
          .get(
        Uri.parse('$baseUrl/matches/player/$playerId'),
      )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        lastError = null;
        return jsonDecode(response.body);
      }

      throw NetworkException(
        'Failed to fetch player match '
            '(${response.statusCode}): ${response.body}',
      );
    } catch (e) {
      if (e is NetworkException) {
        lastError = e.message;
        rethrow;
      }

      lastError = 'Player match request failed: $e';

      throw NetworkException(
        'Unable to connect to backend: $e',
      );
    }
  }

  /// Submit the partner PIN and complete/verify the match.
  static Future<Map<String, dynamic>> completeMatch({
    required String pairId,
    required String playerId,
    String pin = '',
    required int durationMs,
    String userEmail = 'guest@pairquest.app',
  }) async {
    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/matches/complete'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'pairId': pairId,
          'playerId': playerId,
          'pin': pin,
          'durationMs': durationMs,
          'userEmail': userEmail,
        }),
      )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        lastError = null;
        return jsonDecode(response.body);
      }

      throw NetworkException(
        'Match completion failed '
            '(${response.statusCode}): ${response.body}',
      );
    } catch (e) {
      if (e is NetworkException) {
        lastError = e.message;
        rethrow;
      }

      lastError = 'Match completion request failed: $e';

      throw NetworkException(
        'Unable to connect to backend: $e',
      );
    }
  }
  static Future<List<dynamic>> getLeaderboard({
    required String eventCode,
  }) async {
    try {
      final response = await http
          .get(
        Uri.parse('$baseUrl/leaderboard/$eventCode'),
      )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        lastError = null;
        return jsonDecode(response.body);
      }

      throw NetworkException(
        'Failed to fetch leaderboard '
            '(${response.statusCode}): ${response.body}',
      );
    } catch (e) {
      if (e is NetworkException) {
        lastError = e.message;
        rethrow;
      }

      lastError = 'Leaderboard request failed: $e';

      throw NetworkException(
        'Unable to connect to backend: $e',
      );
    }
  }
  static Future<String> getGuestId() async {
    final prefs = await SharedPreferences.getInstance();

    String? guestId = prefs.getString('guest_id');

    if (guestId == null || guestId.isEmpty) {
      guestId = const Uuid().v4();

      await prefs.setString(
        'guest_id',
        guestId,
      );
    }

    return guestId;
  }
}