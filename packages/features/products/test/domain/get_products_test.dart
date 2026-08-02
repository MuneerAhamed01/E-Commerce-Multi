import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:products/products.dart';

import '../helpers/products_test_harness.dart';

void main() {
  late ProductsTestHarness harness;

  setUp(() {
    harness = ProductsTestHarness.create();
  });

  test('GetProducts returns first page with opaque cursor', () async {
    final result = await harness.getProducts(
      const GetProductsParams(page: ProductPageRequest()),
    );

    expect(result.isSuccess, isTrue, reason: result.failureOrNull?.message);
    final page = result.valueOrNull!;
    expect(page.items.length, ProductPageRequest.defaultPageSize);
    expect(page.hasNextPage, isTrue);
    expect(page.nextPageCursor, isNotNull);
    expect(page.nextPageCursor, isA<String>());
    expect(int.tryParse(page.nextPageCursor!), isNull);
    expect(page.totalCount, harness.store.products.length);
  });

  test('GetProducts second page continues without duplicates', () async {
    final first = (await harness.getProducts(
      const GetProductsParams(page: ProductPageRequest()),
    )).valueOrNull!;
    final second = (await harness.getProducts(
      GetProductsParams(page: ProductPageRequest(cursor: first.nextPageCursor)),
    )).valueOrNull!;

    final firstIds = first.items.map((p) => p.id).toSet();
    final secondIds = second.items.map((p) => p.id).toSet();
    expect(firstIds.intersection(secondIds), isEmpty);
    expect(second.items, isNotEmpty);
  });

  test('GetProducts filters by categoryId', () async {
    final categoryId = harness.store.products.first.categoryId;
    final result = await harness.getProducts(
      GetProductsParams(
        page: const ProductPageRequest(pageSize: 50),
        filter: ProductFilter(categoryId: categoryId),
      ),
    );

    final page = result.valueOrNull!;
    expect(page.items, isNotEmpty);
    expect(page.items.every((p) => p.categoryId == categoryId), isTrue);
  });

  test('simulated list failure maps to ServerFailure', () async {
    harness.controls.forceFailure('products.list');
    final result = await harness.getProducts(
      const GetProductsParams(page: ProductPageRequest()),
    );

    expect(result.isFailure, isTrue);
    expect(result.failureOrNull, isA<ServerFailure>());
  });
}
