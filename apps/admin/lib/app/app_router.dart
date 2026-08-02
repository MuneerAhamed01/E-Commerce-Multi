import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import 'placeholders/placeholder_page.dart';
import 'routing/admin_route_extras.dart';
import 'shell/admin_shell.dart';

/// Builds the admin [GoRouter] (docs/09_ROUTING_PLAN.md §3).
GoRouter createAdminRouter({
  required AppConfig appConfig,
  required TenantConfig tenantConfig,
  AuthSessionState session = const AuthSessionState.guest(),
}) {
  return GoRouter(
    initialLocation: SystemRoutes.adminLoginPath,
    debugLogDiagnostics: kDebugMode,
    redirect: (context, state) {
      final name = state.topRoute?.name;
      final extras = name == null ? null : adminRouteExtras[name];
      if (extras == null) {
        return null;
      }

      return RouteGuard.redirect(
        RouteGuardInput(
          app: RouteAppKind.admin,
          matchedLocation: state.matchedLocation,
          access: extras.access,
          appConfig: appConfig,
          tenantConfig: tenantConfig,
          session: session,
          requiredPermission: extras.requiredPermission,
          uri: state.uri,
        ),
      );
    },
    errorBuilder: (context, state) => AppNotFoundScreen(
      homeLabel: 'Back to dashboard',
      onGoHome: () => context.go(SystemRoutes.adminDashboardPath),
    ),
    routes: [
      GoRoute(
        path: SystemRoutes.adminLoginPath,
        name: SystemRoutes.adminLoginName,
        builder: (context, state) => const PlaceholderPage(
          title: 'Admin Login',
          subtitle: 'Admin auth lands in Phase 21.',
        ),
      ),
      GoRoute(
        path: SystemRoutes.adminMaintenancePath,
        name: SystemRoutes.adminMaintenanceName,
        builder: (context, state) => AppMaintenanceScreen(
          onRetry: () => context.go(SystemRoutes.adminDashboardPath),
        ),
      ),
      GoRoute(
        path: SystemRoutes.adminAccessDeniedPath,
        name: SystemRoutes.adminAccessDeniedName,
        builder: (context, state) => AppAccessDeniedScreen(
          onGoHome: () => context.go(SystemRoutes.adminDashboardPath),
        ),
      ),
      if (appConfig.isDeveloperModeAvailable)
        GoRoute(
          path: SystemRoutes.adminDevPanelPath,
          name: SystemRoutes.adminDevPanelName,
          builder: (context, state) => DeveloperPanelPage(
            appConfig: appConfig,
            tenantConfig: tenantConfig,
            title: 'Admin Developer Panel',
          ),
        ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AdminShell(
            navigationShell: navigationShell,
            tenantConfig: tenantConfig,
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: SystemRoutes.adminDashboardPath,
                name: SystemRoutes.adminDashboardName,
                builder: (context, state) => PlaceholderPage(
                  title: 'Dashboard',
                  subtitle: tenantConfig.displayName,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/catalog/products',
                name: 'AdminProductListRoute',
                builder: (context, state) =>
                    const PlaceholderPage(title: 'Products'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/orders',
                name: 'AdminOrderListRoute',
                builder: (context, state) =>
                    const PlaceholderPage(title: 'Orders'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/customers',
                name: 'AdminCustomerListRoute',
                builder: (context, state) =>
                    const PlaceholderPage(title: 'Customers'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/marketing/promotions',
                name: 'AdminPromotionListRoute',
                builder: (context, state) =>
                    const PlaceholderPage(title: 'Promotions'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/tenant/profile',
                name: 'AdminTenantProfileRoute',
                builder: (context, state) =>
                    const PlaceholderPage(title: 'Tenant Profile'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/settings',
                name: 'AdminSettingsRoute',
                builder: (context, state) =>
                    const PlaceholderPage(title: 'Settings'),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
