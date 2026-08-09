import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

/// A selectable shipping option with fixed mock cost.
final class ShippingMethod extends Equatable {
  const ShippingMethod({
    required this.id,
    required this.name,
    required this.description,
    required this.etaLabel,
    required this.cost,
  });

  final String id;
  final String name;
  final String description;
  final String etaLabel;
  final Money cost;

  @override
  List<Object?> get props => [id, name, description, etaLabel, cost];
}
