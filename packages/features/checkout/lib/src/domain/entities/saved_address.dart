import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

/// Address book entry for checkout (id + default flag around core [Address]).
///
/// **Deviation:** Profile address book is not implemented yet — saved
/// addresses live in the checkout mock until Phase 18.
final class SavedAddress extends Equatable {
  const SavedAddress({
    required this.id,
    required this.address,
    this.isDefault = false,
  });

  factory SavedAddress.fromJson(Map<String, dynamic> json) {
    final raw = json['address'] as Map<String, dynamic>? ?? json;
    return SavedAddress(
      id: json['id'] as String,
      isDefault: json['isDefault'] as bool? ?? false,
      address: Address(
        line1: raw['line1'] as String? ?? '',
        line2: raw['line2'] as String?,
        city: raw['city'] as String? ?? '',
        state: raw['state'] as String? ?? '',
        postalCode: raw['postalCode'] as String? ?? '',
        countryCode: raw['countryCode'] as String? ?? 'US',
        label: raw['label'] as String?,
      ),
    );
  }

  final String id;
  final Address address;
  final bool isDefault;

  SavedAddress copyWith({String? id, Address? address, bool? isDefault}) {
    return SavedAddress(
      id: id ?? this.id,
      address: address ?? this.address,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'isDefault': isDefault,
    'address': {
      'line1': address.line1,
      'line2': address.line2,
      'city': address.city,
      'state': address.state,
      'postalCode': address.postalCode,
      'countryCode': address.countryCode,
      'label': address.label,
    },
  };

  @override
  List<Object?> get props => [id, address, isDefault];
}
