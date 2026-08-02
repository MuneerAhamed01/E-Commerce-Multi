import 'package:core/core.dart';

import '../../domain/entities/dashboard_kpi_set.dart';
import '../../domain/entities/sales_trend_point.dart';
import '../mock/admin_dashboard_call_types.dart';
import 'dashboard_analytics_data_source.dart';

/// Deterministic KPI aggregation over [MockSeedStore] orders/products.
final class MockDashboardAnalyticsDataSource
    with MockDataSourceMixin
    implements DashboardAnalyticsDataSource {
  MockDashboardAnalyticsDataSource({
    required this.simulator,
    required MockSeedStore store,
  }) : _store = store; // ignore: prefer_initializing_formals

  @override
  final MockNetworkSimulator simulator;

  final MockSeedStore _store;

  static const _activeStatuses = {'paid', 'shipped', 'delivered', 'pending'};

  @override
  Future<DashboardKpiSet> fetchDashboardKpis() {
    return guarded(AdminDashboardCallTypes.dashboardKpis, () async {
      const currency = SeedData.currencyCode;
      final activeOrders = _store.orders
          .where((o) => _activeStatuses.contains(o.status))
          .toList(growable: false);

      final totalSales = activeOrders.fold<Money>(
        Money.zero(currency),
        (sum, order) => sum + order.total,
      );
      final orderCount = activeOrders.length;
      final averageOrderValue = orderCount == 0
          ? Money.zero(currency)
          : Money(
              minorUnits: (totalSales.minorUnits / orderCount).round(),
              currencyCode: currency,
            );

      final customers = _store.users.where((u) => u.role == 'customer').length;
      final conversionRate = customers == 0
          ? 0.0
          : (orderCount / customers).clamp(0.0, 1.0);

      final salesTrend = _buildSalesTrend(activeOrders, currency);
      final salesDeltaPercent = _salesDeltaPercent(salesTrend);

      final lowStockCount = _store.products.where((p) => p.stock == 0).length;

      return DashboardKpiSet(
        totalSales: totalSales,
        orderCount: orderCount,
        averageOrderValue: averageOrderValue,
        conversionRate: conversionRate.toDouble(),
        salesDeltaPercent: salesDeltaPercent,
        salesTrend: salesTrend,
        catalogProductCount: _store.products.length,
        lowStockCount: lowStockCount,
      );
    });
  }

  List<SalesTrendPoint> _buildSalesTrend(
    List<SeedOrder> orders,
    String currency,
  ) {
    final byDay = <String, _DayBucket>{};
    for (final order in orders) {
      final dayKey = order.createdAtIso.length >= 10
          ? order.createdAtIso.substring(0, 10)
          : order.createdAtIso;
      final bucket = byDay.putIfAbsent(
        dayKey,
        () => _DayBucket(dateIso: dayKey),
      );
      bucket.revenueMinor += order.total.minorUnits;
      bucket.orderCount += 1;
    }

    final sortedKeys = byDay.keys.toList()..sort();
    final recent = sortedKeys.length <= 7
        ? sortedKeys
        : sortedKeys.sublist(sortedKeys.length - 7);

    return [
      for (final key in recent)
        SalesTrendPoint(
          label: _shortLabel(key),
          dateIso: key,
          revenue: Money(
            minorUnits: byDay[key]!.revenueMinor,
            currencyCode: currency,
          ),
          orderCount: byDay[key]!.orderCount,
        ),
    ];
  }

  double _salesDeltaPercent(List<SalesTrendPoint> trend) {
    if (trend.length < 2) {
      return 0;
    }
    final latest = trend.last.revenue.minorUnits.toDouble();
    final previous = trend[trend.length - 2].revenue.minorUnits.toDouble();
    if (previous == 0) {
      return latest == 0 ? 0 : 100;
    }
    return ((latest - previous) / previous) * 100;
  }

  String _shortLabel(String dateIso) {
    final parts = dateIso.split('-');
    if (parts.length != 3) {
      return dateIso;
    }
    return '${parts[1]}/${parts[2]}';
  }
}

final class _DayBucket {
  _DayBucket({required this.dateIso});

  final String dateIso;
  int revenueMinor = 0;
  int orderCount = 0;
}
