import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:products/products.dart';

import '../helpers/products_test_harness.dart';

void main() {
  late ProductsTestHarness harness;

  setUp(() {
    harness = ProductsTestHarness.create();
  });

  test('SubmitProductReview prepends review without restart', () async {
    final productId = harness.store.products.first.id;
    final before = (await harness.getProductReviews(
      GetProductReviewsParams(productId: productId),
    )).valueOrNull!.items;

    final submitted = await harness.submitProductReview(
      SubmitProductReviewParams(
        productId: productId,
        userId: 'user_test',
        userDisplayName: 'Test User',
        rating: 5,
        title: 'Loved it',
        body: 'Great quality for the price.',
      ),
    );

    expect(
      submitted.isSuccess,
      isTrue,
      reason: submitted.failureOrNull?.message,
    );
    final after = (await harness.getProductReviews(
      GetProductReviewsParams(productId: productId),
    )).valueOrNull!.items;

    expect(after.length, before.length + 1);
    expect(after.first.id, submitted.valueOrNull!.id);
    expect(after.first.title, 'Loved it');
  });

  test('submit without userId maps to UnauthorizedFailure', () async {
    final productId = harness.store.products.first.id;
    final result = await harness.submitProductReview(
      SubmitProductReviewParams(
        productId: productId,
        userId: '',
        userDisplayName: 'Ghost',
        rating: 4,
        title: 'Nope',
        body: 'Should fail',
      ),
    );

    expect(result.isFailure, isTrue);
    expect(result.failureOrNull, isA<UnauthorizedFailure>());
  });

  test('reset mock data clears submitted reviews', () async {
    final productId = harness.store.products.first.id;
    await harness.submitProductReview(
      SubmitProductReviewParams(
        productId: productId,
        userId: 'user_test',
        userDisplayName: 'Test User',
        rating: 5,
        title: 'Temp',
        body: 'Will be cleared',
      ),
    );
    final withSubmit = (await harness.getProductReviews(
      GetProductReviewsParams(productId: productId),
    )).valueOrNull!.items;

    harness.controls.resetMockData();

    final afterReset = (await harness.getProductReviews(
      GetProductReviewsParams(productId: productId),
    )).valueOrNull!.items;

    expect(afterReset.any((r) => r.title == 'Temp'), isFalse);
    expect(afterReset.length, lessThan(withSubmit.length));
  });
}
