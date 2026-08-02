import 'package:flutter_test/flutter_test.dart';
import 'package:search/search.dart';

import '../helpers/search_test_harness.dart';

void main() {
  late SearchTestHarness harness;

  setUp(() {
    harness = SearchTestHarness.create();
  });

  test('loads results for a matching query', () async {
    final token = harness.store.products.first.name.split(' ').first;
    final bloc = harness.createResultsBloc()
      ..add(SearchResultsStarted(query: token));

    await expectLater(
      bloc.stream,
      emitsInOrder([
        isA<SearchResultsLoading>(),
        isA<SearchResultsLoaded>().having(
          (s) => s.products,
          'products',
          isNotEmpty,
        ),
      ]),
    );
    await bloc.close();
  });

  test('zero results for nonsense query', () async {
    final bloc = harness.createResultsBloc()
      ..add(const SearchResultsStarted(query: 'zzz-no-such-product-xyz'));

    await expectLater(
      bloc.stream,
      emitsInOrder([
        isA<SearchResultsLoading>(),
        isA<SearchResultsLoaded>().having((s) => s.isEmpty, 'empty', isTrue),
      ]),
    );
    await bloc.close();
  });

  test('apply filter ANDs with query and can zero out results', () async {
    final token = harness.store.products.first.name.split(' ').first;
    final bloc = harness.createResultsBloc()
      ..add(SearchResultsStarted(query: token));

    await bloc.stream.firstWhere((s) => s is SearchResultsLoaded);

    bloc.add(
      const SearchResultsFilterApplied(
        SearchFilter(
          minPriceMinor: 0,
          maxPriceMinor: 1,
          inStockOnly: true,
          minRating: 5,
        ),
      ),
    );

    await expectLater(
      bloc.stream,
      emitsInOrder([
        isA<SearchResultsLoading>(),
        isA<SearchResultsLoaded>().having(
          (s) => s.isEmpty,
          'filtered empty',
          isTrue,
        ),
      ]),
    );
    await bloc.close();
  });
}
