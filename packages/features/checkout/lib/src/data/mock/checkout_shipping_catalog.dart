import 'package:core/core.dart';

import '../../domain/entities/shipping_method.dart';

/// Local shipping catalog for Phase 14 (no remote).
abstract final class CheckoutShippingCatalog {
  static const String unavailablePostalCode = '00000';

  static const List<ShippingMethod> methods = [
    ShippingMethod(
      id: 'ship_standard',
      name: 'Standard',
      description: 'Economy ground shipping',
      etaLabel: '5–7 days',
      cost: Money(minorUnits: 599, currencyCode: 'USD'),
    ),
    ShippingMethod(
      id: 'ship_express',
      name: 'Express',
      description: 'Faster delivery',
      etaLabel: '2–3 days',
      cost: Money(minorUnits: 1299, currencyCode: 'USD'),
    ),
    ShippingMethod(
      id: 'ship_overnight',
      name: 'Overnight',
      description: 'Next-day delivery',
      etaLabel: 'next day',
      cost: Money(minorUnits: 2499, currencyCode: 'USD'),
    ),
  ];

  static ShippingMethod? byId(String id) {
    for (final method in methods) {
      if (method.id == id) {
        return method;
      }
    }
    return null;
  }
}
