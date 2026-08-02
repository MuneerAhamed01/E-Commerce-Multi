import 'package:flutter/material.dart';

/// A single destination in an [AppBottomNavBar].
class AppBottomNavItem {
  const AppBottomNavItem({
    required this.icon,
    required this.label,
    this.selectedIcon,
    this.badgeCount,
  });

  final IconData icon;

  /// Rendered instead of [icon] for the currently-selected destination.
  /// Defaults to [icon] when omitted.
  final IconData? selectedIcon;

  final String label;

  /// When positive, overlays a count badge on this destination's icon
  /// (e.g. the cart item count).
  final int? badgeCount;
}

/// The customer app's bottom navigation, per
/// docs/08_COMPONENT_LIBRARY.md §12 (`AppBottomNavBar`). Used in
/// `apps/storefront`'s persistent shell.
///
/// ```dart
/// AppBottomNavBar(
///   items: [
///     const AppBottomNavItem(icon: Icons.home_outlined, selectedIcon: Icons.home, label: 'Home'),
///     AppBottomNavItem(icon: Icons.shopping_cart_outlined, label: 'Cart', badgeCount: cartCount),
///   ],
///   currentIndex: shellState.currentIndex,
///   onTap: (index) => shellNavigator.goToBranch(index),
/// );
/// ```
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    required this.items,
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final List<AppBottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      destinations: [
        for (final item in items)
          NavigationDestination(
            icon: _iconFor(item, selected: false),
            selectedIcon: _iconFor(item, selected: true),
            label: item.label,
          ),
      ],
    );
  }

  Widget _iconFor(AppBottomNavItem item, {required bool selected}) {
    final iconData = selected ? (item.selectedIcon ?? item.icon) : item.icon;
    final icon = Icon(iconData);
    final badgeCount = item.badgeCount;
    if (badgeCount == null || badgeCount <= 0) {
      return icon;
    }
    return Badge(label: Text('$badgeCount'), child: icon);
  }
}
