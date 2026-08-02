import 'package:flutter/material.dart';

/// Visual treatment of an [AppTopBar]. See docs/08_COMPONENT_LIBRARY.md §12.
enum AppTopBarVariant {
  /// Solid background, standard title/actions layout.
  standard,

  /// Embeds an [AppSearchBar]-style search field in place of the title.
  withSearch,

  /// Transparent until the page scrolls, then transitions to
  /// [standard]'s solid background (driven by [AppTopBar.isScrolled]).
  transparentScroll,
}

/// The platform's primary app bar, per docs/08_COMPONENT_LIBRARY.md §12
/// (`AppTopBar`). Used on every screen; implements [PreferredSizeWidget] so
/// it drops directly into `Scaffold.appBar`.
///
/// For [AppTopBarVariant.withSearch], pass the search field itself as
/// [searchBar] (typically an `AppSearchBar` with
/// `variant: AppSearchBarVariant.shellEmbedded`) rather than [title].
///
/// ```dart
/// Scaffold(
///   appBar: AppTopBar(title: 'Orders', actions: [cartBadgeAction]),
///   body: ...,
/// );
/// ```
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({
    this.title,
    this.variant = AppTopBarVariant.standard,
    this.actions,
    this.leading,
    this.searchBar,
    this.isScrolled = false,
    super.key,
  }) : assert(
         variant != AppTopBarVariant.withSearch || searchBar != null,
         'searchBar is required when variant is AppTopBarVariant.withSearch',
       );

  final String? title;
  final AppTopBarVariant variant;
  final List<Widget>? actions;
  final Widget? leading;

  /// Required when [variant] is [AppTopBarVariant.withSearch].
  final Widget? searchBar;

  /// For [AppTopBarVariant.transparentScroll]: whether the page has
  /// scrolled past the point where the bar should become opaque.
  final bool isScrolled;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  bool get _isTransparent =>
      variant == AppTopBarVariant.transparentScroll && !isScrolled;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: leading,
      title: variant == AppTopBarVariant.withSearch
          ? searchBar
          : (title != null ? Text(title!) : null),
      titleSpacing: variant == AppTopBarVariant.withSearch ? 0 : null,
      actions: actions,
      backgroundColor: _isTransparent ? Colors.transparent : null,
      foregroundColor: _isTransparent ? Colors.white : null,
      elevation: 0,
      scrolledUnderElevation: 0,
    );
  }
}
