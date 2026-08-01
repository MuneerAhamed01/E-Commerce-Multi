import 'package:equatable/equatable.dart';

/// An immutable postal address.
///
/// Used by both Profile (a customer's saved address book) and Checkout
/// (shipping/billing address selection) with no single natural owner
/// feature, so it lives in `core` per
/// docs/05_ARCHITECTURE_GUIDELINES.md §3.
final class Address extends Equatable {
  const Address({
    required this.line1,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.countryCode,
    this.line2,
    this.label,
  });

  /// Street address, line 1 (required).
  final String line1;

  /// Street address, line 2 (apartment/suite/unit) - optional.
  final String? line2;

  final String city;

  /// State/province/region.
  final String state;

  final String postalCode;

  /// ISO 3166-1 alpha-2 country code, e.g. `'US'`.
  final String countryCode;

  /// Optional user-facing label (`'Home'`, `'Work'`), set by the customer
  /// when saving this address - not present for a one-off checkout address.
  final String? label;

  /// A single-line, comma-joined rendering suitable for compact UI
  /// (an order summary row, a collapsed address-picker chip).
  String get singleLine {
    return [
      line1,
      line2,
      city,
      state,
      postalCode,
      countryCode,
    ].where((part) => part != null && part.isNotEmpty).join(', ');
  }

  @override
  List<Object?> get props => [
    line1,
    line2,
    city,
    state,
    postalCode,
    countryCode,
    label,
  ];
}
