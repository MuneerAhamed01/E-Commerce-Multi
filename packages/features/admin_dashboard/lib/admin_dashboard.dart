/// Admin KPI dashboard feature.
///
/// Only symbols exported here are a public contract other packages may depend
/// on (docs/02_PROJECT_STRUCTURE.md §6 / §11).
///
/// Phase 8 ships the KPI shell + mock aggregation; deeper analytics/reports
/// remain Phase 22.
library;

export 'src/domain/entities/dashboard_kpi_set.dart';
export 'src/domain/entities/sales_trend_point.dart';
export 'src/domain/repositories/analytics_repository.dart';
export 'src/domain/usecases/get_dashboard_kpis.dart';
export 'src/injection/admin_dashboard_injection.dart';
export 'src/presentation/bloc/admin_dashboard_bloc.dart';
export 'src/presentation/screens/admin_dashboard_screen.dart';
