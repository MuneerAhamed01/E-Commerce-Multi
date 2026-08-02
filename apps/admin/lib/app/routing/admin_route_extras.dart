import 'package:core/core.dart';

/// Per-route guard metadata for the Phase 5 admin skeleton
/// (docs/09_ROUTING_PLAN.md §3 / §4).
final class AdminRouteExtras {
  const AdminRouteExtras({required this.access, this.requiredPermission});

  final RouteAccess access;
  final AdminPermission? requiredPermission;
}

const adminRouteExtras = <String, AdminRouteExtras>{
  'AdminLoginRoute': AdminRouteExtras(access: RouteAccess.authFlow),
  'AdminMaintenanceRoute': AdminRouteExtras(access: RouteAccess.maintenance),
  // Reachable by any authenticated admin (docs/09_ROUTING_PLAN.md §3.2).
  'AdminAccessDeniedRoute': AdminRouteExtras(
    access: RouteAccess.authenticated,
    requiredPermission: AdminPermission.anyAdmin,
  ),
  'AdminDevPanelRoute': AdminRouteExtras(access: RouteAccess.developer),
  'AdminDashboardRoute': AdminRouteExtras(
    access: RouteAccess.authenticated,
    requiredPermission: AdminPermission.anyAdmin,
  ),
  'AdminProductListRoute': AdminRouteExtras(
    access: RouteAccess.authenticated,
    requiredPermission: AdminPermission.catalogManager,
  ),
  'AdminOrderListRoute': AdminRouteExtras(
    access: RouteAccess.authenticated,
    requiredPermission: AdminPermission.orderManager,
  ),
  'AdminCustomerListRoute': AdminRouteExtras(
    access: RouteAccess.authenticated,
    requiredPermission: AdminPermission.orderManager,
  ),
  'AdminPromotionListRoute': AdminRouteExtras(
    access: RouteAccess.authenticated,
    requiredPermission: AdminPermission.marketingManager,
  ),
  'AdminTenantProfileRoute': AdminRouteExtras(
    access: RouteAccess.authenticated,
    requiredPermission: AdminPermission.superAdmin,
  ),
  'AdminSettingsRoute': AdminRouteExtras(
    access: RouteAccess.authenticated,
    requiredPermission: AdminPermission.anyAdmin,
  ),
};
