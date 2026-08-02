import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Persistent side-nav chrome for the admin app
/// (docs/09_ROUTING_PLAN.md §3.3). Role filtering is applied by the
/// caller via [visibleBranchIndexes]; Phase 5 shows all branches since
/// sessions are guest and shell destinations redirect through the guard.
class AdminShell extends StatelessWidget {
  const AdminShell({
    required this.navigationShell,
    required this.tenantConfig,
    super.key,
  });

  final StatefulNavigationShell navigationShell;
  final TenantConfig tenantConfig;

  static const _items = <AppSideNavItem>[
    AppSideNavItem(
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      label: 'Dashboard',
      route: SystemRoutes.adminDashboardPath,
    ),
    AppSideNavItem(
      icon: Icons.inventory_2_outlined,
      selectedIcon: Icons.inventory_2,
      label: 'Catalog',
      route: '/admin/catalog/products',
    ),
    AppSideNavItem(
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long,
      label: 'Orders',
      route: '/admin/orders',
    ),
    AppSideNavItem(
      icon: Icons.people_outline,
      selectedIcon: Icons.people,
      label: 'Customers',
      route: '/admin/customers',
    ),
    AppSideNavItem(
      icon: Icons.campaign_outlined,
      selectedIcon: Icons.campaign,
      label: 'Marketing',
      route: '/admin/marketing/promotions',
    ),
    AppSideNavItem(
      icon: Icons.apartment_outlined,
      selectedIcon: Icons.apartment,
      label: 'Tenant',
      route: '/admin/tenant/profile',
    ),
    AppSideNavItem(
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      label: 'Settings',
      route: '/admin/settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final mode = AppBreakpoints.isDesktop(context)
        ? AppSideNavMode.expanded
        : AppSideNavMode.collapsed;

    return Scaffold(
      body: Row(
        children: [
          AppSideNav(
            mode: mode,
            items: _items,
            currentRoute: _items[navigationShell.currentIndex].route,
            onSelect: (route) {
              final index = _items.indexWhere((item) => item.route == route);
              if (index >= 0) {
                navigationShell.goBranch(
                  index,
                  initialLocation: index == navigationShell.currentIndex,
                );
              }
            },
          ),
          const VerticalDivider(width: 1),
          Expanded(child: navigationShell),
        ],
      ),
    );
  }
}
