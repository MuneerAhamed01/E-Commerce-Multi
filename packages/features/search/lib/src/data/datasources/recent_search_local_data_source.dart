import 'dart:convert';

import 'package:core/core.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local persistence for recent search strings.
abstract interface class RecentSearchLocalDataSource {
  Future<List<String>> readRecent();

  Future<void> writeRecent(List<String> terms);

  Future<void> clear();
}

final class SharedPreferencesRecentSearchLocalDataSource
    implements RecentSearchLocalDataSource {
  SharedPreferencesRecentSearchLocalDataSource(this._prefs);

  static const String storageKey = 'search.recent';
  static const int maxRecent = 10;

  final SharedPreferences _prefs;

  @override
  Future<List<String>> readRecent() async {
    try {
      final raw = _prefs.getString(storageKey);
      if (raw == null || raw.isEmpty) {
        return const [];
      }
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return const [];
      }
      return decoded.whereType<String>().toList(growable: false);
    } on Object catch (e) {
      throw CacheException('Failed to read recent searches: $e');
    }
  }

  @override
  Future<void> writeRecent(List<String> terms) async {
    try {
      final capped = terms.take(maxRecent).toList(growable: false);
      final ok = await _prefs.setString(storageKey, jsonEncode(capped));
      if (!ok) {
        throw const CacheException('Failed to persist recent searches');
      }
    } on CacheException {
      rethrow;
    } on Object catch (e) {
      throw CacheException('Failed to persist recent searches: $e');
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _prefs.remove(storageKey);
    } on Object catch (e) {
      throw CacheException('Failed to clear recent searches: $e');
    }
  }
}

/// Process-local recent searches for unit tests (no SharedPreferences).
final class InMemoryRecentSearchLocalDataSource
    implements RecentSearchLocalDataSource {
  InMemoryRecentSearchLocalDataSource({List<String>? seed})
    : _terms = List<String>.of(seed ?? const []);

  final List<String> _terms;

  @override
  Future<List<String>> readRecent() async => List<String>.of(_terms);

  @override
  Future<void> writeRecent(List<String> terms) async {
    _terms
      ..clear()
      ..addAll(
        terms.take(SharedPreferencesRecentSearchLocalDataSource.maxRecent),
      );
  }

  @override
  Future<void> clear() async => _terms.clear();
}
