import 'package:cart/cart.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Money money(int minor) => Money(minorUnits: minor, currencyCode: 'USD');

  Cart cartWith(List<CartItem> items) {
    return Cart(ownerId: 'guest', items: items);
  }

  group('CartPricingEngine.compute', () {
    test('empty cart yields zero breakdown', () {
      final pricing = CartPricingEngine.compute(Cart.empty('guest'));
      expect(pricing.subtotal.minorUnits, 0);
      expect(pricing.discount.minorUnits, 0);
      expect(pricing.taxPlaceholder.minorUnits, 0);
      expect(pricing.total.minorUnits, 0);
    });

    test('subtotal is sum of line totals', () {
      final cart = cartWith([
        testLine(productId: 'a', unitPrice: money(1000), quantity: 2),
        testLine(productId: 'b', unitPrice: money(500), quantity: 1),
      ]);
      final pricing = CartPricingEngine.compute(cart);
      expect(pricing.subtotal.minorUnits, 2500);
      expect(pricing.total.minorUnits, 2500);
    });

    test('SAVE10 percent discount', () {
      final cart = cartWith([
        testLine(productId: 'a', unitPrice: money(10000), quantity: 1),
      ]);
      final promo = CartPromoCatalog.definitions()[CartPromoCatalog.save10]!;
      final pricing = CartPricingEngine.compute(cart, promo: promo);
      expect(pricing.discount.minorUnits, 1000);
      expect(pricing.total.minorUnits, 9000);
    });

    test('SAVE5 fixed discount clamped to subtotal', () {
      final cart = cartWith([
        testLine(productId: 'a', unitPrice: money(300), quantity: 1),
      ]);
      final promo = CartPromoCatalog.definitions()[CartPromoCatalog.save5]!;
      final pricing = CartPricingEngine.compute(cart, promo: promo);
      expect(pricing.discount.minorUnits, 300);
      expect(pricing.total.minorUnits, 0);
    });

    test('single promo only — no stacking in engine', () {
      final cart = cartWith([
        testLine(productId: 'a', unitPrice: money(10000), quantity: 1),
      ]);
      final promo = CartPromoCatalog.definitions()[CartPromoCatalog.save10]!;
      final pricing = CartPricingEngine.compute(cart, promo: promo);
      // Engine accepts at most one promo argument; stacking is a caller policy.
      expect(pricing.discount.minorUnits, 1000);
    });
  });

  group('CartPricingEngine.validateQuantity', () {
    test('blocks zero quantity', () {
      final error = CartPricingEngine.validateQuantity(
        quantity: 0,
        maxStock: 5,
      );
      expect(error, isNotNull);
      expect(error!.message, contains('Zero'));
    });

    test('blocks quantity above stock', () {
      final error = CartPricingEngine.validateQuantity(
        quantity: 6,
        maxStock: 5,
      );
      expect(error, isNotNull);
      expect(error!.message, contains('stock'));
    });

    test('capQuantity never exceeds stock', () {
      expect(CartPricingEngine.capQuantity(10, 3), 3);
      expect(CartPricingEngine.capQuantity(0, 3), 1);
      expect(CartPricingEngine.capQuantity(2, 0), 0);
    });
  });

  group('PromoValidator', () {
    late Map<String, PromoDefinition> catalog;

    setUp(() {
      catalog = CartPromoCatalog.definitions(
        clock: () => DateTime.utc(2026, 8, 2),
      );
    });

    test('invalid code', () {
      final result = PromoValidator.validate(
        rawCode: CartPromoCatalog.invalid,
        subtotal: money(5000),
        catalog: catalog,
      );
      expect(result, isA<PromoValidationFailure>());
      expect((result as PromoValidationFailure).message, contains('Invalid'));
    });

    test('expired code', () {
      final result = PromoValidator.validate(
        rawCode: CartPromoCatalog.expired,
        subtotal: money(5000),
        catalog: catalog,
        clock: () => DateTime.utc(2026, 8, 2),
      );
      expect(result, isA<PromoValidationFailure>());
      expect((result as PromoValidationFailure).message, contains('expired'));
    });

    test('min spend not met', () {
      final result = PromoValidator.validate(
        rawCode: CartPromoCatalog.noSpend,
        subtotal: money(5000),
        catalog: catalog,
      );
      expect(result, isA<PromoValidationFailure>());
      expect(
        (result as PromoValidationFailure).message,
        contains('Minimum spend'),
      );
    });

    test('valid SAVE10', () {
      final result = PromoValidator.validate(
        rawCode: 'save10',
        subtotal: money(5000),
        catalog: catalog,
      );
      expect(result, isA<PromoValidationSuccess>());
    });
  });
}
