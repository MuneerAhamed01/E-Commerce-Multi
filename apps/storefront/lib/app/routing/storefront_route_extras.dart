import 'package:authentication/authentication.dart';
import 'package:cart/cart.dart';
import 'package:categories/categories.dart';
import 'package:core/core.dart';
import 'package:products/products.dart';
import 'package:search/search.dart';
import 'package:wishlist/wishlist.dart';

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
  CategoryRoutes.browseName: StorefrontRouteExtras(access: RouteAccess.public),
  CategoryRoutes.detailName: StorefrontRouteExtras(access: RouteAccess.public),
  ProductRoutes.listName: StorefrontRouteExtras(access: RouteAccess.public),
  ProductRoutes.detailName: StorefrontRouteExtras(access: RouteAccess.public),
  SearchRoutes.entryName: StorefrontRouteExtras(access: RouteAccess.public),
  SearchRoutes.resultsName: StorefrontRouteExtras(access: RouteAccess.public),
  CartRoutes.name: StorefrontRouteExtras(access: RouteAccess.public),
  WishlistRoutes.name: StorefrontRouteExtras(
    access: RouteAccess.authenticated,
    requiredFeatureFlag: FeatureFlag.wishlist,
  ),
  'ProfileRoute': StorefrontRouteExtras(access: RouteAccess.authenticated),
  'MaintenanceRoute': StorefrontRouteExtras(access: RouteAccess.maintenance),
  'DevPanelRoute': StorefrontRouteExtras(access: RouteAccess.developer),
};
