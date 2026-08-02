import 'package:authentication/authentication.dart';
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
  AuthSessionState Function()? sessionOf,
  Listenable? refreshListenable,
  AuthSessionState session = const AuthSessionState.guest(),
}) {
  AuthSessionState currentSession() => sessionOf?.call() ?? session;

  return GoRouter(
    initialLocation: AuthRoutes.adminSplashPath,
    debugLogDiagnostics: kDebugMode,
    refreshListenable: refreshListenable,
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
          session: currentSession(),
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
        path: AuthRoutes.adminSplashPath,
        name: AuthRoutes.adminSplashName,
        builder: (context, state) => const SplashScreen(isAdminApp: true),
      ),
      GoRoute(
        path: AuthRoutes.adminLoginPath,
        name: AuthRoutes.adminLoginName,
        builder: (context, state) =>
            const LoginScreen(requireAdmin: true, isAdminApp: true),
      ),
      GoRoute(
        path: AuthRoutes.adminForgotPasswordPath,
        name: AuthRoutes.adminForgotPasswordName,
        builder: (context, state) =>
            const ForgotPasswordScreen(isAdminApp: true),
      ),
      GoRoute(
        path: AuthRoutes.adminVerifyOtpPath,
        name: AuthRoutes.adminVerifyOtpName,
        builder: (context, state) {
          final email =
              state.uri.queryParameters[AuthRoutes.emailQueryKey] ?? '';
          return OtpVerificationScreen(
            email: email,
            purpose: OtpPurpose.passwordReset,
            isAdminApp: true,
          );
        },
      ),
      GoRoute(
        path: AuthRoutes.adminResetPasswordPath,
        name: AuthRoutes.adminResetPasswordName,
        builder: (context, state) {
          final email =
              state.uri.queryParameters[AuthRoutes.emailQueryKey] ?? '';
          return ResetPasswordScreen(email: email, isAdminApp: true);
        },
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
