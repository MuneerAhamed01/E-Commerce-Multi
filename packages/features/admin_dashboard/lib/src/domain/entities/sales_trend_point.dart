import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

/// A single day (or bucket) in the admin sales trend chart.
final class SalesTrendPoint extends Equatable {
  const SalesTrendPoint({
    required this.label,
    required this.dateIso,
    required this.revenue,
    required this.orderCount,
  });

  final String label;
  final String dateIso;
  final Money revenue;
  final int orderCount;

  @override
  List<Object?> get props => [label, dateIso, revenue, orderCount];
}
