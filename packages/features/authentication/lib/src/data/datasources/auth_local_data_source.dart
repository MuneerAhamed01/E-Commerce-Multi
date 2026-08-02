import 'dart:convert';

import 'package:core/core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_session_model.dart';

/// Local persistence for session + onboarding-seen flag.
abstract interface class AuthLocalDataSource {
  Future<AuthSessionModel?> readSession();

  Future<void> writeSession(AuthSessionModel session);

  Future<void> clearSession();

  Future<bool> readOnboardingSeen();

  Future<void> writeOnboardingSeen(bool seen);
}

final class SharedPreferencesAuthLocalDataSource
    implements AuthLocalDataSource {
  SharedPreferencesAuthLocalDataSource(this._prefs);

  static const String sessionKey = 'auth.session';
  static const String onboardingKey = 'auth.onboardingSeen';

  final SharedPreferences _prefs;

  @override
  Future<AuthSessionModel?> readSession() async {
    try {
      final raw = _prefs.getString(sessionKey);
      if (raw == null || raw.isEmpty) {
        return null;
      }
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return AuthSessionModel.fromJson(json);
    } on Object catch (e) {
      throw CacheException('Failed to read auth session: $e');
    }
  }

  @override
  Future<void> writeSession(AuthSessionModel session) async {
    try {
      final ok = await _prefs.setString(
        sessionKey,
        jsonEncode(session.toJson()),
      );
      if (!ok) {
        throw const CacheException('Failed to persist auth session');
      }
    } on CacheException {
      rethrow;
    } on Object catch (e) {
      throw CacheException('Failed to persist auth session: $e');
    }
  }

  @override
  Future<void> clearSession() async {
    try {
      await _prefs.remove(sessionKey);
    } on Object catch (e) {
      throw CacheException('Failed to clear auth session: $e');
    }
  }

  @override
  Future<bool> readOnboardingSeen() async {
    return _prefs.getBool(onboardingKey) ?? false;
  }

  @override
  Future<void> writeOnboardingSeen(bool seen) async {
    try {
      final ok = await _prefs.setBool(onboardingKey, seen);
      if (!ok) {
        throw const CacheException('Failed to persist onboarding flag');
      }
    } on CacheException {
      rethrow;
    } on Object catch (e) {
      throw CacheException('Failed to persist onboarding flag: $e');
    }
  }
}
