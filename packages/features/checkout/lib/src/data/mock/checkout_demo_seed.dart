import 'package:core/core.dart';

import '../../domain/entities/checkout_payment_method.dart';
import '../../domain/entities/saved_address.dart';

/// Demo seeds for checkout address book + payment methods.
///
/// Demo customer: `user_cust_02` / `noah.patel02@example.com`.
abstract final class CheckoutDemoSeed {
  static const String demoCustomerId = 'user_cust_02';

  static final List<SavedAddress> demoAddresses = List.unmodifiable([
    const SavedAddress(
      id: 'addr_home_02',
      isDefault: true,
      address: Address(
        line1: '742 Evergreen Terrace',
        line2: 'Apt 2B',
        city: 'Springfield',
        state: 'IL',
        postalCode: '62704',
        countryCode: 'US',
        label: 'Home',
      ),
    ),
    const SavedAddress(
      id: 'addr_work_02',
      address: Address(
        line1: '100 Market Street',
        city: 'Chicago',
        state: 'IL',
        postalCode: '60601',
        countryCode: 'US',
        label: 'Work',
      ),
    ),
  ]);

  static final List<CheckoutPaymentMethod> paymentMethods = List.unmodifiable([
    const CheckoutPaymentMethod(
      id: 'pay_visa_4242',
      brandLabel: 'Visa',
      last4: '4242',
      type: CheckoutPaymentType.card,
      isDefault: true,
    ),
    const CheckoutPaymentMethod(
      id: 'pay_cod',
      brandLabel: 'Cash on Delivery',
      type: CheckoutPaymentType.cod,
    ),
  ]);
}
