import 'package:cart/cart.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    return BlocBuilder<CartBloc, CartState>(
      buildWhen: (prev, next) => prev.itemCount != next.itemCount,
      builder: (context, cartState) {
        final cartCount = cartState.itemCount;
        final wishlistEnabled = tenantConfig.featureFlags.isEnabled(
          FeatureFlag.wishlist,
        );

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
          AppBottomNavItem(
            icon: Icons.shopping_cart_outlined,
            selectedIcon: Icons.shopping_cart,
            label: 'Cart',
            badgeCount: cartCount > 0 ? cartCount : null,
          ),
          if (wishlistEnabled)
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

        // Shell branches: 0 home, 1 categories, 2 search, 3 cart,
        // 4 wishlist (always present, guarded), 5 profile.
        final branchForNavIndex = <int>[
          0,
          1,
          2,
          3,
          if (wishlistEnabled) 4,
          wishlistEnabled ? 5 : 4,
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
      },
    );
  }
}
