import 'package:flutter_test/flutter_test.dart';
import 'package:search/src/data/datasources/recent_search_local_data_source.dart';
import 'package:search/src/data/repositories/recent_search_repository_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('InMemoryRecentSearchLocalDataSource', () {
    test('save prepends, dedupes case-insensitively, caps at 10', () async {
      final local = InMemoryRecentSearchLocalDataSource();
      final repo = RecentSearchRepositoryImpl(local: local);

      for (var i = 0; i < 12; i++) {
        await repo.saveRecentSearch('term $i');
      }
      await repo.saveRecentSearch('TERM 11');

      final recent = (await repo.getRecentSearches()).valueOrNull!;
      expect(recent.length, 10);
      expect(recent.first, 'TERM 11');
      expect(recent.where((t) => t.toLowerCase() == 'term 11').length, 1);
    });

    test('clear empties list', () async {
      final local = InMemoryRecentSearchLocalDataSource(seed: const ['a']);
      final repo = RecentSearchRepositoryImpl(local: local);
      await repo.clearRecentSearches();
      expect((await repo.getRecentSearches()).valueOrNull, isEmpty);
    });
  });

  group('SharedPreferencesRecentSearchLocalDataSource', () {
    test('persists across reads', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final local = SharedPreferencesRecentSearchLocalDataSource(prefs);
      final repo = RecentSearchRepositoryImpl(local: local);

      await repo.saveRecentSearch('wireless');
      await repo.saveRecentSearch('classic');

      final again = SharedPreferencesRecentSearchLocalDataSource(prefs);
      final terms = await again.readRecent();
      expect(terms, ['classic', 'wireless']);
    });
  });
}
