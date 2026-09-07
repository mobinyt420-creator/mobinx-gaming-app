import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../constants/app_constants.dart';

/// Mobin X Enterprise Local Storage & Session Manager
class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // --- USER SESSION ---
  static Future<void> saveUser(UserModel user) async {
    await _prefs?.setString(AppConstants.keyUserSession, jsonEncode(user.toJson()));
  }

  static UserModel? getUser() {
    final raw = _prefs?.getString(AppConstants.keyUserSession);
    if (raw == null || raw.isEmpty) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return UserModel.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  static Future<void> clearUser() async {
    await _prefs?.remove(AppConstants.keyUserSession);
  }

  // --- ONBOARDING STATUS ---
  static bool isOnboardingDone() {
    return _prefs?.getBool(AppConstants.keyOnboardingDone) ?? false;
  }

  static Future<void> setOnboardingDone(bool done) async {
    await _prefs?.setBool(AppConstants.keyOnboardingDone, done);
  }

  // --- GENERIC JSON CACHE ---
  static Future<void> setCache(String key, dynamic data) async {
    await _prefs?.setString(key, jsonEncode(data));
  }

  static dynamic getCache(String key) {
    final raw = _prefs?.getString(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw);
    } catch (e) {
      return null;
    }
  }
}
