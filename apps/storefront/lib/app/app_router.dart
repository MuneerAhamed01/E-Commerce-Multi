import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import 'placeholders/placeholder_page.dart';
import 'routing/storefront_route_extras.dart';
import 'shell/storefront_shell.dart';

/// Builds the storefront [GoRouter] (docs/09_ROUTING_PLAN.md §2).
///
/// Feature packages will contribute their own `<feature>_routes.dart` lists
/// in later phases; Phase 5 only wires the shell skeleton, auth-flow
/// stubs, maintenance/404, and the optional developer panel.
GoRouter createStorefrontRouter({
  required AppConfig appConfig,
  required TenantConfig tenantConfig,
  AuthSessionState session = const AuthSessionState.guest(),
}) {
  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: kDebugMode,
    redirect: (context, state) {
      final name = state.topRoute?.name;
      final extras = name == null ? null : storefrontRouteExtras[name];
      if (extras == null) {
        return null;
      }

      var access = extras.access;
      // Guest browsing gate for catalog-ish public routes.
      if (access == RouteAccess.public &&
          !_isAlwaysPublic(name) &&
          !tenantConfig.allowGuestBrowsing &&
          !session.isAuthenticated) {
        access = RouteAccess.authenticated;
      }

      return RouteGuard.redirect(
        RouteGuardInput(
          app: RouteAppKind.storefront,
          matchedLocation: state.matchedLocation,
          access: access,
          appConfig: appConfig,
          tenantConfig: tenantConfig,
          session: session,
          requiredFeatureFlag: extras.requiredFeatureFlag,
          uri: state.uri,
        ),
      );
    },
    errorBuilder: (context, state) => AppNotFoundScreen(
      onGoHome: () => context.go(SystemRoutes.storefrontHomePath),
    ),
    routes: [
      GoRoute(
        path: '/splash',
        name: 'SplashRoute',
        redirect: (context, state) {
          if (!tenantConfig.allowGuestBrowsing && !session.isAuthenticated) {
            return SystemRoutes.storefrontLoginPath;
          }
          return SystemRoutes.storefrontHomePath;
        },
      ),
      GoRoute(
        path: SystemRoutes.storefrontLoginPath,
        name: SystemRoutes.storefrontLoginName,
        builder: (context, state) => const PlaceholderPage(
          title: 'Login',
          subtitle: 'Auth screens land in Phase 7.',
        ),
      ),
      GoRoute(
        path: '/register',
        name: 'RegisterRoute',
        builder: (context, state) => const PlaceholderPage(
          title: 'Register',
          subtitle: 'Auth screens land in Phase 7.',
        ),
      ),
      GoRoute(
        path: SystemRoutes.storefrontMaintenancePath,
        name: SystemRoutes.storefrontMaintenanceName,
        builder: (context, state) => AppMaintenanceScreen(
          onRetry: () => context.go(SystemRoutes.storefrontHomePath),
        ),
      ),
      if (appConfig.isDeveloperModeAvailable)
        GoRoute(
          path: SystemRoutes.storefrontDevPanelPath,
          name: SystemRoutes.storefrontDevPanelName,
          builder: (context, state) => DeveloperPanelPage(
            appConfig: appConfig,
            tenantConfig: tenantConfig,
          ),
        ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return StorefrontShell(
            navigationShell: navigationShell,
            tenantConfig: tenantConfig,
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: SystemRoutes.storefrontHomePath,
                name: SystemRoutes.storefrontHomeName,
                builder: (context, state) => PlaceholderPage(
                  title: 'Home',
                  subtitle: tenantConfig.displayName,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/categories',
                name: 'CategoryBrowseRoute',
                builder: (context, state) =>
                    const PlaceholderPage(title: 'Categories'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                name: 'SearchRoute',
                builder: (context, state) =>
                    const PlaceholderPage(title: 'Search'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/wishlist',
                name: 'WishlistRoute',
                builder: (context, state) =>
                    const PlaceholderPage(title: 'Wishlist'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: 'ProfileRoute',
                builder: (context, state) =>
                    const PlaceholderPage(title: 'Profile'),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

bool _isAlwaysPublic(String? name) {
  return name == 'SplashRoute' ||
      name == SystemRoutes.storefrontLoginName ||
      name == 'RegisterRoute' ||
      name == SystemRoutes.storefrontMaintenanceName ||
      name == SystemRoutes.storefrontDevPanelName;
}
