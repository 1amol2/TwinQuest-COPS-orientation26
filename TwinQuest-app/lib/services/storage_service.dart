import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _userBoxName = 'user_data_box';
  static const String _matchesBoxName = 'matches_history_box';

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    try {
      await Hive.initFlutter();
      await Hive.openBox(_userBoxName);
      await Hive.openBox(_matchesBoxName);
      _initialized = true;
    } catch (_) {
      // Fallback if Hive fails in web/test environment
    }
  }

  // --- Auth & User Profile Management ---

  static Future<void> saveUser({
    required String name,
    required String email,
    required String avatar,
    required String authType, // 'GOOGLE', 'GUEST', 'STAFF'
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    await prefs.setString('user_email', email);
    await prefs.setString('user_avatar', avatar);
    await prefs.setString('auth_type', authType);
    await prefs.setBool('is_logged_in', true);

    if (_initialized) {
      final box = Hive.box(_userBoxName);
      await box.put('name', name);
      await box.put('email', email);
      await box.put('avatar', avatar);
      await box.put('authType', authType);
    }
  }

  static Future<Map<String, String>> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString('user_name') ?? '',
      'email': prefs.getString('user_email') ?? '',
      'avatar': prefs.getString('user_avatar') ?? '⚡',
      'authType': prefs.getString('auth_type') ?? 'GUEST',
    };
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (_initialized) {
      await Hive.box(_userBoxName).clear();
    }
  }

  // --- Match History Persistence (Only for Google/Registered Accounts) ---

  static Future<void> saveMatch({
    required String partnerName,
    required String timeFormatted,
    required int durationMs,
    required String avatar,
  }) async {
    final user = await getUser();
    // Do NOT save match to database or local history if Guest Login!
    if (user['authType'] == 'GUEST') return;

    final newMatch = {
      'name': partnerName,
      'time': timeFormatted,
      'durationMs': durationMs,
      'date': 'Today',
      'avatar': avatar,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    final prefs = await SharedPreferences.getInstance();
    final List<String> matchesRaw = prefs.getStringList('saved_matches') ?? [];
    matchesRaw.insert(0, jsonEncode(newMatch));
    await prefs.setStringList('saved_matches', matchesRaw);

    if (_initialized) {
      final box = Hive.box(_matchesBoxName);
      await box.add(newMatch);
    }
  }

  static Future<List<Map<String, dynamic>>> getSavedMatches() async {
    final user = await getUser();
    if (user['authType'] == 'GUEST') return []; // Guests have no saved database history

    final prefs = await SharedPreferences.getInstance();
    final List<String> matchesRaw = prefs.getStringList('saved_matches') ?? [];
    final List<Map<String, dynamic>> result = [];
    for (String m in matchesRaw) {
      try {
        result.add(Map<String, dynamic>.from(jsonDecode(m)));
      } catch (_) {}
    }
    return result;
  }
}
