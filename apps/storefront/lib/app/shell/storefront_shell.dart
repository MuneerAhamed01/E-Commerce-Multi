import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Persistent bottom-nav chrome for the storefront
/// (docs/09_ROUTING_PLAN.md §2.4).
class StorefrontShell extends StatelessWidget {
  const StorefrontShell({
    required this.navigationShell,
    required this.tenantConfig,
    super.key,
  });

  final StatefulNavigationShell navigationShell;
  final TenantConfig tenantConfig;

  @override
  Widget build(BuildContext context) {
    final items = <AppBottomNavItem>[
      const AppBottomNavItem(
        icon: Icons.home_outlined,
        selectedIcon: Icons.home,
        label: 'Home',
      ),
      const AppBottomNavItem(
        icon: Icons.category_outlined,
        selectedIcon: Icons.category,
        label: 'Categories',
      ),
      const AppBottomNavItem(
        icon: Icons.search,
        selectedIcon: Icons.search,
        label: 'Search',
      ),
      if (tenantConfig.featureFlags.isEnabled(FeatureFlag.wishlist))
        const AppBottomNavItem(
          icon: Icons.favorite_border,
          selectedIcon: Icons.favorite,
          label: 'Wishlist',
        ),
      const AppBottomNavItem(
        icon: Icons.person_outline,
        selectedIcon: Icons.person,
        label: 'Profile',
      ),
    ];

    // Map visible nav index → shell branch index. Wishlist branch is
    // always present in the router (guarded) so branch indexes stay
    // stable; when the flag is off we skip that nav item and remap taps.
    final branchForNavIndex = <int>[
      0, // home
      1, // categories
      2, // search
      if (tenantConfig.featureFlags.isEnabled(FeatureFlag.wishlist)) 3,
      tenantConfig.featureFlags.isEnabled(FeatureFlag.wishlist) ? 4 : 3,
    ];

    final currentNavIndex = branchForNavIndex.indexOf(
      navigationShell.currentIndex,
    );

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppBottomNavBar(
        items: items,
        currentIndex: currentNavIndex < 0 ? 0 : currentNavIndex,
        onTap: (index) {
          navigationShell.goBranch(
            branchForNavIndex[index],
            initialLocation: index == currentNavIndex,
          );
        },
      ),
    );
  }
}
