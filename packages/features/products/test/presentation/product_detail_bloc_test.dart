import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:products/products.dart';

import '../helpers/products_test_harness.dart';

void main() {
  late ProductsTestHarness harness;
  late String productId;

  setUp(() {
    harness = ProductsTestHarness.create();
    productId = harness.store.products
        .firstWhere((p) => p.id.endsWith('5') || p.id.endsWith('0'))
        .id;
  });

  blocTest<ProductDetailBloc, ProductDetailState>(
    'loads detail then variant selection updates selected id',
    build: () => harness.createDetailBloc(),
    act: (bloc) async {
      bloc.add(ProductDetailStarted(productId));
      final loaded =
          await bloc.stream.firstWhere((s) => s is ProductDetailLoaded)
              as ProductDetailLoaded;
      final other = loaded.product.variants.firstWhere(
        (v) => v.id != loaded.selectedVariantId,
      );
      bloc.add(ProductVariantSelected(other.id));
    },
    expect: () => [
      const ProductDetailLoading(),
      isA<ProductDetailLoaded>(),
      isA<ProductDetailLoaded>().having(
        (s) => s.selectedVariantId,
        'selected variant changed',
        isNot(productId),
      ),
    ],
    verify: (bloc) {
      final state = bloc.state as ProductDetailLoaded;
      expect(state.selectedVariant.id, state.selectedVariantId);
      expect(state.product.variants.length, greaterThan(1));
    },
  );

  blocTest<ProductDetailBloc, ProductDetailState>(
    'add to cart on OOS variant emits status message',
    build: () => harness.createDetailBloc(),
    act: (bloc) async {
      bloc.add(ProductDetailStarted(productId));
      final loaded =
          await bloc.stream.firstWhere((s) => s is ProductDetailLoaded)
              as ProductDetailLoaded;
      final oos = loaded.product.variants.firstWhere((v) => !v.isInStock);
      bloc.add(ProductVariantSelected(oos.id));
      await bloc.stream.firstWhere(
        (s) => s is ProductDetailLoaded && s.selectedVariantId == oos.id,
      );
      bloc.add(const ProductAddToCartPressed());
    },
    verify: (bloc) {
      final state = bloc.state as ProductDetailLoaded;
      expect(state.canAddToCart, isFalse);
      expect(state.statusMessage, contains('out of stock'));
    },
  );
}
