import 'package:core/core.dart';

import '../../domain/entities/checkout_payment_method.dart';
import '../../domain/entities/saved_address.dart';
import '../../domain/entities/shipping_method.dart';

/// Remote contract for checkout support data (mock-only).
abstract class CheckoutRemoteDataSource {
  Future<List<SavedAddress>> fetchSavedAddresses(String userId);

  Future<SavedAddress> saveAddress({
    required String userId,
    required Address address,
    bool makeDefault = false,
  });

  Future<List<ShippingMethod>> fetchShippingMethods();

  Future<Money> calculateShippingCost({
    required String methodId,
    required String postalCode,
  });

  Future<List<CheckoutPaymentMethod>> fetchPaymentMethods(String userId);
}
