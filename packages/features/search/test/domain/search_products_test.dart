import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:products/products.dart';
import 'package:search/search.dart';

import '../helpers/search_test_harness.dart';

void main() {
  late SearchTestHarness harness;

  setUp(() {
    harness = SearchTestHarness.create();
  });

  test('SearchProducts matches seed catalog names', () async {
    final sample = harness.store.products.first;
    final token = sample.name.split(' ').first;

    final result = await harness.searchProducts(
      SearchProductsParams(
        query: token,
        page: const ProductPageRequest(pageSize: 50),
      ),
    );

    expect(result.isSuccess, isTrue, reason: result.failureOrNull?.message);
    final page = result.valueOrNull!;
    expect(page.items, isNotEmpty);
    expect(
      page.items.every(
        (p) =>
            p.name.toLowerCase().contains(token.toLowerCase()) ||
            p.description.toLowerCase().contains(token.toLowerCase()),
      ),
      isTrue,
    );
  });

  test('SearchProducts paginates large result sets', () async {
    final result = await harness.searchProducts(
      const SearchProductsParams(
        query: '',
        page: ProductPageRequest(),
      ),
    );
    final page = result.valueOrNull!;
    expect(page.items.length, 20);
    expect(page.hasNextPage, isTrue);
    expect(page.totalCount, harness.store.products.length);
  });

  test('simulated search failure maps to ServerFailure', () async {
    harness.controls.forceFailure('search.products');
    final result = await harness.searchProducts(
      const SearchProductsParams(query: 'classic', page: ProductPageRequest()),
    );
    expect(result.isFailure, isTrue);
    expect(result.failureOrNull, isA<ServerFailure>());
  });

  test('GetSearchSuggestions returns product suggestions', () async {
    final token = harness.store.products.first.name.split(' ').first;
    final result = await harness.getSearchSuggestions(
      GetSearchSuggestionsParams(token),
    );
    expect(result.isSuccess, isTrue);
    expect(result.valueOrNull, isNotEmpty);
  });
}
