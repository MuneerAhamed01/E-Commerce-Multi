import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/admin_dashboard_test_harness.dart';

void main() {
  late AdminDashboardTestHarness harness;

  setUp(() {
    harness = AdminDashboardTestHarness.create();
  });

  test('GetDashboardKpis aggregates sales from seed orders', () async {
    final result = await harness.getDashboardKpis(const NoParams());

    expect(result.isSuccess, isTrue, reason: result.failureOrNull?.message);
    final kpis = result.valueOrNull!;
    expect(kpis.orderCount, greaterThan(0));
    expect(kpis.totalSales.minorUnits, greaterThan(0));
    expect(kpis.catalogProductCount, harness.store.products.length);
    expect(kpis.salesTrend, isNotEmpty);
    expect(kpis.averageOrderValue.minorUnits, greaterThan(0));
    expect(kpis.conversionRate, greaterThan(0));
    expect(kpis.conversionRate, lessThanOrEqualTo(1));
  });

  test('non-active order statuses are excluded from sales totals', () async {
    // Must match MockDashboardAnalyticsDataSource._activeStatuses.
    const activeStatuses = {'paid', 'shipped', 'delivered', 'pending'};
    final result = await harness.getDashboardKpis(const NoParams());
    final kpis = result.valueOrNull!;
    final activeCount = harness.store.orders
        .where((o) => activeStatuses.contains(o.status))
        .length;

    expect(kpis.orderCount, activeCount);
  });

  test('empty orders still report catalog metrics', () async {
    harness.store.orders.clear();
    final result = await harness.getDashboardKpis(const NoParams());
    final kpis = result.valueOrNull!;

    expect(result.isSuccess, isTrue);
    expect(kpis.orderCount, 0);
    expect(kpis.totalSales.isZero, isTrue);
    expect(kpis.catalogProductCount, greaterThan(0));
  });

  test('simulated failure maps to ServerFailure', () async {
    harness.controls.forceFailure('admin_dashboard.kpis');
    final result = await harness.getDashboardKpis(const NoParams());

    expect(result.isFailure, isTrue);
    expect(result.failureOrNull, isA<ServerFailure>());
  });
}
