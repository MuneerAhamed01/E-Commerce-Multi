import 'package:flutter_test/flutter_test.dart';
import 'package:search/search.dart';

import '../helpers/search_test_harness.dart';

void main() {
  late SearchTestHarness harness;

  setUp(() {
    harness = SearchTestHarness.create();
  });

  test('SearchStarted loads empty recent + trending', () async {
    final bloc = harness.createSearchBloc()..add(const SearchStarted());
    await expectLater(
      bloc.stream,
      emits(
        isA<SearchEntryLoaded>()
            .having((s) => s.recentSearches, 'recent', isEmpty)
            .having((s) => s.trendingTerms, 'trending', isNotEmpty),
      ),
    );
    await bloc.close();
  });

  test('SearchQueryChanged loads suggestions after presentation debounce', () async {
    final bloc = harness.createSearchBloc();
    final token = harness.store.products.first.name.split(' ').first;

    bloc.add(const SearchStarted());
    await bloc.stream.firstWhere((s) => s is SearchEntryLoaded);

    bloc.add(SearchQueryChanged(token));
    await expectLater(
      bloc.stream,
      emitsInOrder([
        isA<SearchEntryLoaded>().having(
          (s) => s.isSuggesting,
          'loading',
          isTrue,
        ),
        isA<SearchEntryLoaded>()
            .having((s) => s.isSuggesting, 'done', isFalse)
            .having((s) => s.suggestions, 'suggestions', isNotEmpty),
      ]),
    );
    await bloc.close();
  });

  test('SearchSubmitted emits navigate then restores entry with recent', () async {
    final bloc = harness.createSearchBloc();
    bloc.add(const SearchStarted());
    await bloc.stream.firstWhere((s) => s is SearchEntryLoaded);

    bloc.add(const SearchSubmitted('classic'));
    await expectLater(
      bloc.stream,
      emitsInOrder([
        isA<SearchEntryLoaded>().having(
          (s) => s.recentSearches,
          'recent before nav',
          contains('classic'),
        ),
        isA<SearchNavigateToResults>().having((s) => s.query, 'q', 'classic'),
        isA<SearchEntryLoaded>().having(
          (s) => s.recentSearches.first,
          'recent after',
          'classic',
        ),
      ]),
    );
    await bloc.close();
  });
}
