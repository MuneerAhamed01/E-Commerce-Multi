import 'package:authentication/authentication.dart';
import 'package:cart/cart.dart';
import 'package:categories/categories.dart';
import 'package:checkout/checkout.dart';
import 'package:core/core.dart';
import 'package:dashboard/dashboard.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:orders/orders.dart';
import 'package:products/products.dart';
import 'package:search/search.dart';
import 'package:wishlist/wishlist.dart';

import 'cart/storefront_cart_actions.dart';
import 'checkout/storefront_checkout_actions.dart';
import 'routing/storefront_route_extras.dart';
import 'shell/storefront_shell.dart';
import 'wishlist/storefront_wishlist_actions.dart';

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
      GoRoute(
        path: ProductRoutes.listPath,
        name: ProductRoutes.listName,
        builder: (context, state) {
          final categoryId =
              state.uri.queryParameters[ProductRoutes.categoryIdQueryKey];
          return ProductListScreen(
            categoryId: categoryId,
            wishlistActionBuilder: StorefrontWishlistActions.cardToggle,
          );
        },
      ),
      GoRoute(
        path: '/products/:productId',
        name: ProductRoutes.detailName,
        builder: (context, state) {
          final productId = state.pathParameters['productId'] ?? '';
          return ProductDetailScreen(
            productId: productId,
            wishlistActionBuilder: StorefrontWishlistActions.detailToggle,
            relatedWishlistActionBuilder: StorefrontWishlistActions.cardToggle,
            onAddToCart: StorefrontCartActions.addFromDetail,
          );
        },
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
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: CategoryRoutes.browsePath,
                name: CategoryRoutes.browseName,
                builder: (context, state) => const CategoryBrowseScreen(),
                routes: [
                  GoRoute(
                    path: ':categoryId',
                    name: CategoryRoutes.detailName,
                    builder: (context, state) {
                      final categoryId =
                          state.pathParameters['categoryId'] ?? '';
                      return CategoryDetailScreen(
                        key: ValueKey(categoryId),
                        categoryId: categoryId,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: SearchRoutes.entryPath,
                name: SearchRoutes.entryName,
                builder: (context, state) => const SearchEntryScreen(),
                routes: [
                  GoRoute(
                    path: 'results',
                    name: SearchRoutes.resultsName,
                    builder: (context, state) {
                      final query =
                          state.uri.queryParameters[SearchRoutes.queryKey] ??
                          '';
                      final sortName =
                          state.uri.queryParameters[SearchRoutes.sortKey];
                      final sort = SortOption.values.firstWhere(
                        (option) => option.name == sortName,
                        orElse: () => SortOption.relevance,
                      );
                      return SearchResultsScreen(
                        key: ValueKey('search-results-$query-${sort.name}'),
                        query: query,
                        initialSort: sort,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: CartRoutes.path,
                name: CartRoutes.name,
                builder: (context, state) => CartScreen(
                  onCheckoutNavigate: () => navigateToCheckout(context),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: WishlistRoutes.path,
                name: WishlistRoutes.name,
                builder: (context, state) => const WishlistScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: 'ProfileRoute',
                builder: (context, state) => Scaffold(
                  appBar: AppBar(title: const Text('Profile')),
                  body: ListView(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.receipt_long_outlined),
                        title: const Text('My orders'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push(OrderRoutes.historyPath),
                      ),
                      const Divider(height: 1),
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Full profile arrives in Phase 18.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: OrderRoutes.historyPath,
        name: OrderRoutes.historyName,
        builder: (context, state) => const OrderHistoryScreen(),
        routes: [
          GoRoute(
            path: ':orderId',
            name: OrderRoutes.detailName,
            builder: (context, state) {
              final orderId = state.pathParameters['orderId'] ?? '';
              return OrderDetailScreen(orderId: orderId);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/checkout',
        redirect: (context, state) {
          if (state.uri.path == '/checkout') {
            return CheckoutRoutes.addressPath;
          }
          return null;
        },
        routes: [
          ShellRoute(
            builder: (context, state, child) =>
                CheckoutWizardScope(child: child),
            routes: [
              GoRoute(
                path: 'address',
                name: CheckoutRoutes.addressName,
                builder: (context, state) => const CheckoutAddressScreen(),
              ),
              GoRoute(
                path: 'shipping-payment',
                name: CheckoutRoutes.shippingPaymentName,
                builder: (context, state) =>
                    const CheckoutShippingPaymentScreen(),
              ),
              GoRoute(
                path: 'review',
                name: CheckoutRoutes.reviewName,
                builder: (context, state) => const CheckoutReviewScreen(),
              ),
            ],
          ),
          GoRoute(
            path: 'confirmation/:orderId',
            name: CheckoutRoutes.confirmationName,
            builder: (context, state) {
              final orderId = state.pathParameters['orderId'] ?? '';
              return CheckoutConfirmationScreen(orderId: orderId);
            },
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
