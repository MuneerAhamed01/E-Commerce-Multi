import 'package:core/core.dart';

import '../entities/checkout_payment_method.dart';
import '../entities/saved_address.dart';
import '../entities/shipping_method.dart';

/// Checkout support data (addresses, shipping, payment methods).
///
/// Order creation goes through `orders.OrderRepository`; cart clear via cart.
abstract class CheckoutRepository {
  Future<Result<Failure, List<SavedAddress>>> getSavedAddresses(String userId);

  Future<Result<Failure, SavedAddress>> saveAddress({
    required String userId,
    required Address address,
    bool makeDefault = false,
  });

  Future<Result<Failure, List<ShippingMethod>>> getShippingMethods();

  /// Returns shipping cost for [methodId], or failure when unavailable for
  /// [postalCode] (mock rule: `00000`).
  Future<Result<Failure, Money>> calculateShippingCost({
    required String methodId,
    required String postalCode,
  });

  Future<Result<Failure, List<CheckoutPaymentMethod>>> getPaymentMethods(
    String userId,
  );
}
