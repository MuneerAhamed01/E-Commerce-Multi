import 'package:flutter/material.dart';

import '../../tokens/app_radii.dart';

/// Shape preset for an [AppShimmerPlaceholder]. See
/// docs/08_COMPONENT_LIBRARY.md §8.
enum AppShimmerVariant {
  /// A large rounded rectangle, sized for a card-shaped skeleton.
  card,

  /// A short, fully-rounded bar sized for a list tile's leading/title area.
  listTile,

  /// A thin, fully-rounded bar sized for a single line of text.
  textLine,

  /// A rounded rectangle with no default aspect ratio - the caller supplies
  /// [AppShimmerPlaceholder.width]/[AppShimmerPlaceholder.height].
  image,
}

/// A skeleton loading block with a sweeping shimmer animation, per
/// docs/08_COMPONENT_LIBRARY.md §8 (`ShimmerPlaceholder`). Used for
/// `ProductCard` grid loading, list loading, and dashboard KPI loading
/// (`AppKpiCard.isLoading`).
///
/// ```dart
/// AppShimmerPlaceholder(variant: AppShimmerVariant.textLine, width: 120, height: 14);
/// ```
class AppShimmerPlaceholder extends StatefulWidget {
  const AppShimmerPlaceholder({
    this.variant = AppShimmerVariant.textLine,
    this.width,
    this.height,
    super.key,
  });

  final AppShimmerVariant variant;
  final double? width;
  final double? height;

  @override
  State<AppShimmerPlaceholder> createState() => _AppShimmerPlaceholderState();
}

class _AppShimmerPlaceholderState extends State<AppShimmerPlaceholder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  (double, double) get _defaultSize => switch (widget.variant) {
    AppShimmerVariant.card => (double.infinity, 160),
    AppShimmerVariant.listTile => (double.infinity, 56),
    AppShimmerVariant.textLine => (120, 12),
    AppShimmerVariant.image => (double.infinity, 120),
  };

  double get _borderRadius => switch (widget.variant) {
    AppShimmerVariant.card => AppRadii.md,
    AppShimmerVariant.listTile => AppRadii.sm,
    AppShimmerVariant.textLine => AppRadii.xs,
    AppShimmerVariant.image => AppRadii.sm,
  };

  @override
  Widget build(BuildContext context) {
    final (defaultWidth, defaultHeight) = _defaultSize;
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    final highlight = Theme.of(context).colorScheme.surface;

    return Semantics(
      label: 'Loading',
      child: SizedBox(
        width: widget.width ?? defaultWidth,
        height: widget.height ?? defaultHeight,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(_borderRadius),
                gradient: LinearGradient(
                  begin: Alignment(-1 - _controller.value * 2, 0),
                  end: Alignment(1 - _controller.value * 2, 0),
                  colors: [base, highlight, base],
                  stops: const [0.35, 0.5, 0.65],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
