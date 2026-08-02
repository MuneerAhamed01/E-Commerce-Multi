import 'package:authentication/authentication.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import 'placeholders/placeholder_page.dart';
import 'routing/storefront_route_extras.dart';
import 'shell/storefront_shell.dart';

/// Builds the storefront [GoRouter] (docs/09_ROUTING_PLAN.md §2).
GoRouter createStorefrontRouter({
  required AppConfig appConfig,
  required TenantConfig tenantConfig,
  AuthSessionState Function()? sessionOf,
  Listenable? refreshListenable,
  AuthSessionState session = const AuthSessionState.guest(),
}) {
  AuthSessionState currentSession() => sessionOf?.call() ?? session;

  return GoRouter(
    initialLocation: AuthRoutes.splashPath,
    debugLogDiagnostics: kDebugMode,
    refreshListenable: refreshListenable,
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
          !currentSession().isAuthenticated) {
        access = RouteAccess.authenticated;
      }

      return RouteGuard.redirect(
        RouteGuardInput(
          app: RouteAppKind.storefront,
          matchedLocation: state.matchedLocation,
          access: access,
          appConfig: appConfig,
          tenantConfig: tenantConfig,
          session: currentSession(),
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
        path: AuthRoutes.splashPath,
        name: AuthRoutes.splashName,
        builder: (context, state) => const SplashScreen(isAdminApp: false),
      ),
      GoRoute(
        path: AuthRoutes.onboardingPath,
        name: AuthRoutes.onboardingName,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AuthRoutes.loginPath,
        name: AuthRoutes.loginName,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AuthRoutes.registerPath,
        name: AuthRoutes.registerName,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AuthRoutes.forgotPasswordPath,
        name: AuthRoutes.forgotPasswordName,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AuthRoutes.verifyOtpPath,
        name: AuthRoutes.verifyOtpName,
        builder: (context, state) {
          final email =
              state.uri.queryParameters[AuthRoutes.emailQueryKey] ?? '';
          final purposeName =
              state.uri.queryParameters[AuthRoutes.purposeQueryKey];
          final purpose = purposeName == OtpPurpose.registration.name
              ? OtpPurpose.registration
              : OtpPurpose.passwordReset;
          return OtpVerificationScreen(email: email, purpose: purpose);
        },
      ),
      GoRoute(
        path: AuthRoutes.resetPasswordPath,
        name: AuthRoutes.resetPasswordName,
        builder: (context, state) {
          final email =
              state.uri.queryParameters[AuthRoutes.emailQueryKey] ?? '';
          return ResetPasswordScreen(email: email);
        },
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
  return name == AuthRoutes.splashName ||
      name == AuthRoutes.onboardingName ||
      name == AuthRoutes.loginName ||
      name == AuthRoutes.registerName ||
      name == AuthRoutes.forgotPasswordName ||
      name == AuthRoutes.verifyOtpName ||
      name == AuthRoutes.resetPasswordName ||
      name == SystemRoutes.storefrontMaintenanceName ||
      name == SystemRoutes.storefrontDevPanelName;
}
