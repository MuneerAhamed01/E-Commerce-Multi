/// Path/name constants for cross-cutting routes owned by the routing
/// foundation (not a feature package) — docs/09_ROUTING_PLAN.md §7–§8.
///
/// Feature routes keep their own named constants inside their feature
/// packages; only maintenance / 404 landing targets / access-denied live
/// here so [RouteGuard] can redirect without importing an app.
abstract final class SystemRoutes {
  // --- Storefront ---
  static const String storefrontMaintenancePath = '/maintenance';
  static const String storefrontMaintenanceName = 'MaintenanceRoute';

  static const String storefrontLoginPath = '/login';
  static const String storefrontLoginName = 'LoginRoute';

  static const String storefrontHomePath = '/home';
  static const String storefrontHomeName = 'HomeRoute';

  static const String storefrontDevPanelPath = '/dev-panel';
  static const String storefrontDevPanelName = 'DevPanelRoute';

  // --- Admin ---
  static const String adminMaintenancePath = '/admin/maintenance';
  static const String adminMaintenanceName = 'AdminMaintenanceRoute';

  static const String adminLoginPath = '/admin/login';
  static const String adminLoginName = 'AdminLoginRoute';

  static const String adminDashboardPath = '/admin/dashboard';
  static const String adminDashboardName = 'AdminDashboardRoute';

  static const String adminAccessDeniedPath = '/admin/access-denied';
  static const String adminAccessDeniedName = 'AdminAccessDeniedRoute';

  static const String adminDevPanelPath = '/admin/dev-panel';
  static const String adminDevPanelName = 'AdminDevPanelRoute';

  /// Query key used when bouncing an unauthenticated user to login
  /// (docs/09_ROUTING_PLAN.md §4 rule 2).
  static const String redirectQueryKey = 'redirect';
}
