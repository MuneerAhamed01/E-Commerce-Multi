/// Cross-cutting infrastructure for the White Label Commerce Platform.
///
/// This package has zero dependency on Flutter, on any feature package, or
/// on either app - it sits at the base of the dependency graph
/// (see docs/02_PROJECT_STRUCTURE.md §4 and §13).
///
/// Covers error handling (Phase 2), use case/pagination contracts
/// (Phase 2), DI bootstrap (Phase 2), logging/network contracts (Phase 2),
/// shared entities/validators/formatters (Phase 2), configuration
/// (`AppConfig`/`TenantConfig`/`FeatureFlags`, Phase 3), and routing
/// guards (Phase 5), and mock data infrastructure (Phase 6) - see
/// docs/03_DEVELOPMENT_PHASES.md.
library;

export 'config/app_config.dart';
export 'config/feature_flags.dart';
export 'config/tenant_config.dart';
export 'di/injection_container.dart';
export 'error/exception.dart';
export 'error/failure.dart';
export 'error/result.dart';
export 'logging/app_logger.dart';
export 'mock/mock.dart';
export 'network/api_client.dart';
export 'network/network_info.dart';
export 'pagination/paginated_result.dart';
export 'routing/admin_permission.dart';
export 'routing/auth_session_state.dart';
export 'routing/route_guard.dart';
export 'routing/system_routes.dart';
export 'shared_entities/address.dart';
export 'shared_entities/money.dart';
export 'usecase/usecase.dart';
export 'utils/formatters.dart';
export 'utils/validators.dart';
