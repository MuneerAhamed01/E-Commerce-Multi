import 'package:cart/cart.dart';
import 'package:checkout/checkout.dart';
import 'package:checkout/src/data/mock/checkout_shipping_catalog.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orders/orders.dart';

import '../helpers/checkout_test_harness.dart';

class _MockOrderRepository extends Mock implements OrderRepository {}

class _MockCartRepository extends Mock implements CartRepository {}

class _MockCheckoutRepository extends Mock implements CheckoutRepository {}

void main() {
  late CheckoutTestHarness harness;

  setUp(() async {
    harness = await CheckoutTestHarness.create();
  });

  tearDown(() async {
    await harness.dispose();
  });

  group('CalculateShippingCost', () {
    test('returns catalog price for Standard', () async {
      final result = await harness.calculateShippingCost(
        const CalculateShippingCostParams(
          methodId: 'ship_standard',
          postalCode: '78701',
        ),
      );
      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull!.minorUnits, 599);
    });

    test('fails for postal code 00000', () async {
      final result = await harness.calculateShippingCost(
        const CalculateShippingCostParams(
          methodId: 'ship_standard',
          postalCode: CheckoutShippingCatalog.unavailablePostalCode,
        ),
      );
      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<ValidationFailure>());
    });
  });

  group('PlaceOrder', () {
    test('creates order and clears cart', () async {
      await harness.seedCartLine();
      final beforeOrders = harness.store.orders.length;

      final addresses = await harness.getSavedAddresses(
        GetSavedAddressesParams(harness.userId),
      );
      expect(addresses.isSuccess, isTrue);
      final addressList = addresses.valueOrNull!;
      final shipping = CheckoutShippingCatalog.methods.first;
      final payments = await harness.getCheckoutPaymentMethods(
        GetCheckoutPaymentMethodsParams(harness.userId),
      );
      final payment = payments.valueOrNull!.first;

      final result = await harness.placeOrder(
        PlaceOrderParams(
          customerId: harness.userId,
          session: CheckoutSession(
            selectedAddressId: addressList.first.id,
            shippingMethodId: shipping.id,
            paymentMethodId: payment.id,
          ),
          addresses: addressList,
          shippingMethod: shipping,
          paymentMethod: payment,
        ),
      );

      expect(result.isSuccess, isTrue);
      final order = result.valueOrNull!;
      expect(order.status, OrderStatus.placed);
      expect(order.shippingMethodLabel, shipping.name);
      expect(order.paymentMethodLabel, payment.displayLabel);
      expect(harness.store.orders.length, beforeOrders + 1);
      final cart = await harness.cartRepository.getCart(harness.userId);
      expect(cart.valueOrNull!.isEmpty, isTrue);
    });

    test('mocktail PlaceOrder creates once and clears cart', () async {
      final orders = _MockOrderRepository();
      final cartRepo = _MockCartRepository();
      final checkoutRepo = _MockCheckoutRepository();

      registerFallbackValue(
        CreateOrderRequest(
          customerId: 'x',
          items: const [],
          shippingAddress: const Address(
            line1: '1',
            city: 'A',
            state: 'B',
            postalCode: '1',
            countryCode: 'US',
          ),
          subtotal: Money.zero('USD'),
          shipping: Money.zero('USD'),
          tax: Money.zero('USD'),
          total: Money.zero('USD'),
        ),
      );

      const cart = Cart(
        ownerId: 'user_cust_02',
        items: [
          CartItem(
            productId: 'p1',
            variantId: 'v1',
            productName: 'Item',
            variantLabel: 'Default',
            unitPrice: Money(minorUnits: 1000, currencyCode: 'USD'),
            quantity: 1,
            maxStock: 5,
          ),
        ],
      );

      when(
        () => cartRepo.getCart(any()),
      ).thenAnswer((_) async => const Result.success(cart));
      when(
        () => cartRepo.clearCart(any()),
      ).thenAnswer((_) async => Result.success(Cart.empty('user_cust_02')));
      when(
        () => checkoutRepo.calculateShippingCost(
          methodId: any(named: 'methodId'),
          postalCode: any(named: 'postalCode'),
        ),
      ).thenAnswer(
        (_) async =>
            const Result.success(Money(minorUnits: 599, currencyCode: 'USD')),
      );
      when(() => orders.createOrder(any())).thenAnswer((invocation) async {
        final request =
            invocation.positionalArguments.first as CreateOrderRequest;
        return Result.success(
          Order(
            id: 'ord_1',
            orderNumber: 'WL-1',
            customerId: request.customerId,
            status: OrderStatus.placed,
            createdAt: DateTime.utc(2026, 8, 9),
            items: request.items,
            shippingAddress: request.shippingAddress,
            subtotal: request.subtotal,
            shipping: request.shipping,
            tax: request.tax,
            total: request.total,
            paymentMethodLabel: request.paymentMethodLabel,
            shippingMethodLabel: request.shippingMethodLabel,
          ),
        );
      });

      final useCase = PlaceOrder(
        getCartSummary: GetCartSummary(cartRepo),
        clearCart: ClearCart(cartRepo),
        orderRepository: orders,
        checkoutRepository: checkoutRepo,
      );

      final shipping = CheckoutShippingCatalog.methods.first;
      const payment = CheckoutPaymentMethod(
        id: 'pay_visa_4242',
        brandLabel: 'Visa',
        last4: '4242',
        type: CheckoutPaymentType.card,
        isDefault: true,
      );
      const address = SavedAddress(
        id: 'addr_1',
        isDefault: true,
        address: Address(
          line1: '1',
          city: 'A',
          state: 'B',
          postalCode: '62704',
          countryCode: 'US',
        ),
      );

      final result = await useCase(
        PlaceOrderParams(
          customerId: 'user_cust_02',
          session: const CheckoutSession(
            selectedAddressId: 'addr_1',
            shippingMethodId: 'ship_standard',
            paymentMethodId: 'pay_visa_4242',
          ),
          addresses: const [address],
          shippingMethod: shipping,
          paymentMethod: payment,
        ),
      );

      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull!.paymentMethodLabel, payment.displayLabel);
      expect(result.valueOrNull!.shippingMethodLabel, shipping.name);
      verify(() => orders.createOrder(any())).called(1);
      verify(() => cartRepo.clearCart(any())).called(1);
    });
  });
}
