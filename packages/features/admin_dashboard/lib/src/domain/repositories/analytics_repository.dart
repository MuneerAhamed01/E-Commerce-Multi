import 'package:core/core.dart';

import '../entities/dashboard_kpi_set.dart';

/// Derives admin dashboard figures from orders/products mock data.
abstract interface class AnalyticsRepository {
  Future<Result<Failure, DashboardKpiSet>> getDashboardKpis();
}
