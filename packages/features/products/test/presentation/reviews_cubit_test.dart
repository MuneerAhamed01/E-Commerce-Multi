import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:products/products.dart';

import '../helpers/products_test_harness.dart';

void main() {
  late ProductsTestHarness harness;
  late String productId;

  setUp(() {
    harness = ProductsTestHarness.create();
    productId = harness.store.products.first.id;
  });

  blocTest<ReviewsCubit, ReviewsState>(
    'submit when authenticated prepends review in loaded state',
    build: () => harness.createReviewsCubit(),
    act: (cubit) async {
      await cubit.load(productId);
      await cubit.submit(
        userId: 'user_auth',
        userDisplayName: 'Auth User',
        rating: 5,
        title: 'Excellent',
        body: 'Would buy again.',
      );
    },
    expect: () => [
      const ReviewsLoading(),
      isA<ReviewsLoaded>(),
      isA<ReviewsLoaded>().having((s) => s.isSubmitting, 'submitting', true),
      isA<ReviewsLoaded>()
          .having((s) => s.submitSucceeded, 'succeeded', true)
          .having((s) => s.reviews.first.title, 'title', 'Excellent'),
    ],
  );
}
