import 'package:core/core.dart';

import '../entities/dashboard_kpi_set.dart';
import '../repositories/analytics_repository.dart';

/// Loads aggregated admin dashboard KPIs (+ sales trend points).
final class GetDashboardKpis extends UseCase<DashboardKpiSet, NoParams> {
  const GetDashboardKpis(this._repository);

  final AnalyticsRepository _repository;

  @override
  Future<Result<Failure, DashboardKpiSet>> call(NoParams params) {
    return _repository.getDashboardKpis();
  }
}
