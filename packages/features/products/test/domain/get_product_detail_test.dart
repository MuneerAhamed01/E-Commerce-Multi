import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:products/products.dart';

import '../helpers/products_test_harness.dart';

void main() {
  late ProductsTestHarness harness;

  setUp(() {
    harness = ProductsTestHarness.create();
  });

  test('GetProductDetail returns product with variants', () async {
    final id = harness.store.products.first.id;
    final result = await harness.getProductDetail(GetProductDetailParams(id));

    expect(result.isSuccess, isTrue, reason: result.failureOrNull?.message);
    final product = result.valueOrNull!;
    expect(product.id, id);
    expect(product.variants, isNotEmpty);
    expect(product.images, isNotEmpty);
  });

  test('multi-variant demo products expose size/color options', () async {
    final multi = harness.store.products.firstWhere(
      (p) => p.id.endsWith('5') || p.id.endsWith('0'),
    );
    final product = (await harness.getProductDetail(
      GetProductDetailParams(multi.id),
    )).valueOrNull!;

    expect(product.variants.length, greaterThan(2));
    expect(product.variants.any((v) => !v.isInStock), isTrue);
  });

  test('missing product maps to NotFoundFailure', () async {
    final result = await harness.getProductDetail(
      const GetProductDetailParams('prod_does_not_exist'),
    );

    expect(result.isFailure, isTrue);
    expect(result.failureOrNull, isA<NotFoundFailure>());
  });

  test('simulated detail failure maps to ServerFailure', () async {
    harness.controls.forceFailure('products.detail');
    final id = harness.store.products.first.id;
    final result = await harness.getProductDetail(GetProductDetailParams(id));

    expect(result.isFailure, isTrue);
    expect(result.failureOrNull, isA<ServerFailure>());
  });
}
