import 'package:core/core.dart';

/// Per-route guard metadata attached via [GoRouterState.extra] lookup by
/// route name (docs/09_ROUTING_PLAN.md §4).
final class StorefrontRouteExtras {
  const StorefrontRouteExtras({required this.access, this.requiredFeatureFlag});

  final RouteAccess access;
  final FeatureFlag? requiredFeatureFlag;
}

/// Named-route → guard metadata for the Phase 5 storefront skeleton.
const storefrontRouteExtras = <String, StorefrontRouteExtras>{
  'SplashRoute': StorefrontRouteExtras(access: RouteAccess.public),
  'LoginRoute': StorefrontRouteExtras(access: RouteAccess.authFlow),
  'RegisterRoute': StorefrontRouteExtras(access: RouteAccess.authFlow),
  'HomeRoute': StorefrontRouteExtras(access: RouteAccess.public),
  'CategoryBrowseRoute': StorefrontRouteExtras(access: RouteAccess.public),
  'SearchRoute': StorefrontRouteExtras(access: RouteAccess.public),
  'WishlistRoute': StorefrontRouteExtras(
    access: RouteAccess.authenticated,
    requiredFeatureFlag: FeatureFlag.wishlist,
  ),
  'ProfileRoute': StorefrontRouteExtras(access: RouteAccess.authenticated),
  'MaintenanceRoute': StorefrontRouteExtras(access: RouteAccess.maintenance),
  'DevPanelRoute': StorefrontRouteExtras(access: RouteAccess.developer),
};
