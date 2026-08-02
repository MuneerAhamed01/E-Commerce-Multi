import 'package:flutter/material.dart';

/// A single destination in an [AppSideNav].
///
/// [route] is an opaque identifier the caller matches against
/// [AppSideNav.currentRoute] - `design_system` doesn't know about
/// `go_router`'s route constants.
class AppSideNavItem {
  const AppSideNavItem({
    required this.icon,
    required this.label,
    required this.route,
    this.selectedIcon,
  });

  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final String route;
}

/// Display density of an [AppSideNav]. See docs/08_COMPONENT_LIBRARY.md §12.
enum AppSideNavMode {
  /// Icon + label, for wide viewports.
  expanded,

  /// Icon only, for narrower desktop/tablet viewports.
  collapsed,
}

/// The admin app's side navigation, per docs/08_COMPONENT_LIBRARY.md §12
/// (`AppSideNav`). Used in `apps/admin`'s shell.
///
/// Role-based visibility is the caller's responsibility: pass only the
/// [items] the current admin's role permits (docs/06_DEVELOPMENT_RULES.md
/// Rule 41 - hiding a nav item is not itself the security boundary, but
/// this widget still must not render items the caller didn't include).
///
/// ```dart
/// AppSideNav(
///   mode: AppBreakpoints.isDesktop(context) ? AppSideNavMode.expanded : AppSideNavMode.collapsed,
///   items: roleFilteredNavItems,
///   currentRoute: state.matchedLocation,
///   onSelect: (route) => context.go(route),
/// );
/// ```
class AppSideNav extends StatelessWidget {
  const AppSideNav({
    required this.items,
    required this.currentRoute,
    required this.onSelect,
    this.mode = AppSideNavMode.expanded,
    super.key,
  });

  final List<AppSideNavItem> items;
  final String currentRoute;
  final ValueChanged<String> onSelect;
  final AppSideNavMode mode;

  @override
  Widget build(BuildContext context) {
    final selectedIndex = items.indexWhere(
      (item) => item.route == currentRoute,
    );

    return NavigationRail(
      extended: mode == AppSideNavMode.expanded,
      selectedIndex: selectedIndex >= 0 ? selectedIndex : null,
      onDestinationSelected: (index) => onSelect(items[index].route),
      // `extended` (above) governs label visibility when true; `none` here
      // keeps the collapsed rail icon-only rather than showing labels
      // beneath each icon.
      labelType: NavigationRailLabelType.none,
      destinations: [
        for (final item in items)
          NavigationRailDestination(
            icon: Icon(item.icon),
            selectedIcon: Icon(item.selectedIcon ?? item.icon),
            label: Text(item.label),
          ),
      ],
    );
  }
}
