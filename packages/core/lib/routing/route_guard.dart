import '../config/app_config.dart';
import '../config/feature_flags.dart';
import '../config/tenant_config.dart';
import 'admin_permission.dart';
import 'auth_session_state.dart';
import 'system_routes.dart';

/// Which app shell is evaluating the redirect
/// (docs/09_ROUTING_PLAN.md §4).
enum RouteAppKind { storefront, admin }

/// How a matched route participates in guard evaluation.
enum RouteAccess {
  /// Always reachable (subject only to maintenance / feature-flag checks).
  public,

  /// Requires [AuthSessionState.isAuthenticated].
  authenticated,

  /// Login / register / forgot-password / OTP — bounce away if already
  /// authenticated (docs/09_ROUTING_PLAN.md §4 rule 6).
  authFlow,

  /// The maintenance screen itself — never redirected away for maintenance.
  maintenance,

  /// Access-denied landing — reachable by any authenticated admin.
  accessDenied,

  /// Registered only when [AppConfig.isDeveloperModeAvailable] is true.
  developer,
}

/// Inputs for a single redirect evaluation. Built by each app's
/// `GoRouter.redirect` from the matched route's metadata — `core` never
/// imports `go_router` (keeps the package Flutter-free).
final class RouteGuardInput {
  const RouteGuardInput({
    required this.app,
    required this.matchedLocation,
    required this.access,
    required this.appConfig,
    required this.tenantConfig,
    required this.session,
    this.requiredPermission,
    this.requiredFeatureFlag,
    this.uri,
  });

  final RouteAppKind app;
  final String matchedLocation;
  final RouteAccess access;
  final AppConfig appConfig;
  final TenantConfig tenantConfig;
  final AuthSessionState session;

  /// Admin-only: permission required to enter the route.
  final AdminPermission? requiredPermission;

  /// When set and disabled for the tenant, the route is treated as absent
  /// (404) rather than forbidden — docs/09_ROUTING_PLAN.md §4 rule 5 /
  /// docs/06_DEVELOPMENT_RULES.md Rule 39.
  final FeatureFlag? requiredFeatureFlag;

  /// Full request URI (for preserving `?redirect=` etc.). Optional in unit
  /// tests.
  final Uri? uri;
}

/// Shared redirect logic for both apps (docs/09_ROUTING_PLAN.md §4).
///
/// Returns a new location to navigate to, or `null` to allow the navigation.
abstract final class RouteGuard {
  /// Evaluates rules 1→6 in documented order.
  static String? redirect(RouteGuardInput input) {
    final maintenancePath = _maintenancePath(input.app);
    final loginPath = _loginPath(input.app);
    final landingPath = _landingPath(input.app);

    // 1. Maintenance
    final inMaintenance = switch (input.app) {
      RouteAppKind.storefront => input.appConfig.storefrontMaintenanceMode,
      RouteAppKind.admin => input.appConfig.adminMaintenanceMode,
    };
    if (inMaintenance && input.access != RouteAccess.maintenance) {
      // Admin SuperAdmin override path (future): allow disabling maintenance.
      // Phase 5: everyone is redirected while the flag is on.
      return maintenancePath;
    }

    // 2. Auth
    if (input.access == RouteAccess.authenticated &&
        !input.session.isAuthenticated) {
      final redirectTarget = Uri.encodeComponent(input.matchedLocation);
      return '$loginPath?${SystemRoutes.redirectQueryKey}=$redirectTarget';
    }

    // 3. Role / permission (admin)
    if (input.app == RouteAppKind.admin &&
        input.requiredPermission != null &&
        input.access == RouteAccess.authenticated) {
      if (!input.session.hasPermission(input.requiredPermission!)) {
        return SystemRoutes.adminAccessDeniedPath;
      }
    }

    // 5. Feature flag — disabled features look absent (404 sentinel), not
    //    forbidden (docs/06_DEVELOPMENT_RULES.md Rule 39).
    if (input.requiredFeatureFlag != null &&
        !input.tenantConfig.featureFlags.isEnabled(
          input.requiredFeatureFlag!,
        )) {
      return _notFoundSentinel(input.app);
    }

    // Developer routes: defense in depth if a stale deep link arrives when
    // developer mode is off (prod builds should not register these at all).
    if (input.access == RouteAccess.developer &&
        !input.appConfig.isDeveloperModeAvailable) {
      return _notFoundSentinel(input.app);
    }

    // 6. Already authenticated at an auth-flow route
    if (input.access == RouteAccess.authFlow && input.session.isAuthenticated) {
      final pending = input.uri?.queryParameters[SystemRoutes.redirectQueryKey];
      if (pending != null && pending.isNotEmpty) {
        return Uri.decodeComponent(pending);
      }
      return landingPath;
    }

    return null;
  }

  /// Builds the post-login destination (docs/09_ROUTING_PLAN.md §4 rule 4).
  static String postLoginLocation({
    required RouteAppKind app,
    required Uri loginUri,
  }) {
    final pending = loginUri.queryParameters[SystemRoutes.redirectQueryKey];
    if (pending != null && pending.isNotEmpty) {
      return Uri.decodeComponent(pending);
    }
    return _landingPath(app);
  }

  static String _maintenancePath(RouteAppKind app) => switch (app) {
    RouteAppKind.storefront => SystemRoutes.storefrontMaintenancePath,
    RouteAppKind.admin => SystemRoutes.adminMaintenancePath,
  };

  static String _loginPath(RouteAppKind app) => switch (app) {
    RouteAppKind.storefront => SystemRoutes.storefrontLoginPath,
    RouteAppKind.admin => SystemRoutes.adminLoginPath,
  };

  static String _landingPath(RouteAppKind app) => switch (app) {
    RouteAppKind.storefront => SystemRoutes.storefrontHomePath,
    RouteAppKind.admin => SystemRoutes.adminDashboardPath,
  };

  /// Deep-link into the router's errorBuilder by using a guaranteed-unknown
  /// path (not a registered route).
  static String _notFoundSentinel(RouteAppKind app) => switch (app) {
    RouteAppKind.storefront => '/__not_found__',
    RouteAppKind.admin => '/admin/__not_found__',
  };
}
