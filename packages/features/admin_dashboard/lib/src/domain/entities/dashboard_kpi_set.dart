import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

import 'sales_trend_point.dart';

/// At-a-glance admin KPI aggregate derived from seed orders/products.
final class DashboardKpiSet extends Equatable {
  const DashboardKpiSet({
    required this.totalSales,
    required this.orderCount,
    required this.averageOrderValue,
    required this.conversionRate,
    required this.salesDeltaPercent,
    required this.salesTrend,
    required this.catalogProductCount,
    required this.lowStockCount,
  });

  final Money totalSales;
  final int orderCount;
  final Money averageOrderValue;

  /// Placeholder conversion ratio (`0.0`–`1.0`) until analytics ships.
  final double conversionRate;

  /// Percent change vs prior comparison window (deterministic mock).
  final double salesDeltaPercent;

  final List<SalesTrendPoint> salesTrend;
  final int catalogProductCount;

  /// Products with `stock == 0` in the seed store.
  final int lowStockCount;

  bool get isEmpty => orderCount == 0 && catalogProductCount == 0;

  @override
  List<Object?> get props => [
    totalSales,
    orderCount,
    averageOrderValue,
    conversionRate,
    salesDeltaPercent,
    salesTrend,
    catalogProductCount,
    lowStockCount,
  ];
}
