import 'package:flutter/material.dart';

/// The kind of live suggestion an [AppSearchSuggestionTile] represents, per
/// docs/08_COMPONENT_LIBRARY.md §6 (`SearchSuggestionTile` variants).
/// Determines the default leading icon when [AppSearchSuggestionTile.leading]
/// isn't supplied.
enum AppSearchSuggestionKind { product, category, queryCompletion }

/// A row-style live search suggestion, per docs/08_COMPONENT_LIBRARY.md §6
/// (`SearchSuggestionTile`).
///
/// Deliberately decoupled from any domain entity (`Product`/`Category`
/// don't exist yet - see docs/03_DEVELOPMENT_PHASES.md Phase 9/10): the
/// Search feature maps its own suggestion model to this generic
/// `title`/`subtitle`/[leading] shape at the presentation boundary.
///
/// ```dart
/// AppSearchSuggestionTile(
///   kind: AppSearchSuggestionKind.product,
///   title: 'Running Shoes - Men\'s',
///   subtitle: 'Footwear',
///   onTap: () => router.go('/products/$productId'),
/// );
/// ```
class AppSearchSuggestionTile extends StatelessWidget {
  const AppSearchSuggestionTile({
    required this.title,
    required this.onTap,
    this.kind = AppSearchSuggestionKind.queryCompletion,
    this.subtitle,
    this.leading,
    super.key,
  });

  final String title;
  final String? subtitle;
  final AppSearchSuggestionKind kind;

  /// Overrides the kind-derived default leading icon (e.g. a product
  /// thumbnail).
  final Widget? leading;

  final VoidCallback onTap;

  IconData get _defaultIcon => switch (kind) {
    AppSearchSuggestionKind.product => Icons.inventory_2_outlined,
    AppSearchSuggestionKind.category => Icons.category_outlined,
    AppSearchSuggestionKind.queryCompletion => Icons.search,
  };

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading ?? Icon(_defaultIcon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      onTap: onTap,
    );
  }
}
