import '../../domain/entities/dashboard_kpi_set.dart';

abstract interface class DashboardAnalyticsDataSource {
  Future<DashboardKpiSet> fetchDashboardKpis();
}
