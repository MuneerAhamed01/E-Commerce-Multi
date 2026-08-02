import 'package:authentication/authentication.dart';
import 'package:core/core.dart';
import 'package:products/products.dart';

/// Per-route guard metadata attached via [GoRouterState.extra] lookup by
/// route name (docs/09_ROUTING_PLAN.md §4).
final class StorefrontRouteExtras {
  const StorefrontRouteExtras({required this.access, this.requiredFeatureFlag});

  final RouteAccess access;
  final FeatureFlag? requiredFeatureFlag;
}

/// Named-route → guard metadata for the storefront skeleton + auth routes.
const storefrontRouteExtras = <String, StorefrontRouteExtras>{
  AuthRoutes.splashName: StorefrontRouteExtras(access: RouteAccess.public),
  AuthRoutes.onboardingName: StorefrontRouteExtras(access: RouteAccess.public),
  AuthRoutes.loginName: StorefrontRouteExtras(access: RouteAccess.authFlow),
  AuthRoutes.registerName: StorefrontRouteExtras(access: RouteAccess.authFlow),
  AuthRoutes.forgotPasswordName: StorefrontRouteExtras(
    access: RouteAccess.authFlow,
  ),
  AuthRoutes.verifyOtpName: StorefrontRouteExtras(access: RouteAccess.authFlow),
  AuthRoutes.resetPasswordName: StorefrontRouteExtras(
    access: RouteAccess.authFlow,
  ),
  'HomeRoute': StorefrontRouteExtras(access: RouteAccess.public),
  'CategoryBrowseRoute': StorefrontRouteExtras(access: RouteAccess.public),
  ProductRoutes.listName: StorefrontRouteExtras(access: RouteAccess.public),
  ProductRoutes.detailName: StorefrontRouteExtras(access: RouteAccess.public),
  'SearchRoute': StorefrontRouteExtras(access: RouteAccess.public),
  'WishlistRoute': StorefrontRouteExtras(
    access: RouteAccess.authenticated,
    requiredFeatureFlag: FeatureFlag.wishlist,
  ),
  'ProfileRoute': StorefrontRouteExtras(access: RouteAccess.authenticated),
  'MaintenanceRoute': StorefrontRouteExtras(access: RouteAccess.maintenance),
  'DevPanelRoute': StorefrontRouteExtras(access: RouteAccess.developer),
};
