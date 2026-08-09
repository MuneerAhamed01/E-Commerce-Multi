import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

/// A single line on a placed [Order].
final class OrderLineItem extends Equatable {
  const OrderLineItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    this.variantId,
    this.variantLabel,
  });

  final String productId;
  final String productName;
  final int quantity;
  final Money unitPrice;
  final String? variantId;
  final String? variantLabel;

  Money get lineTotal => unitPrice * quantity;

  @override
  List<Object?> get props => [
    productId,
    productName,
    quantity,
    unitPrice,
    variantId,
    variantLabel,
  ];
}
