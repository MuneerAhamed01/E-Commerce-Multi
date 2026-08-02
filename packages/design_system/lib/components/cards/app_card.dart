import 'package:flutter/material.dart';

import '../../theme/theme_extensions.dart';
import '../../tokens/app_elevation.dart';
import '../../tokens/app_radii.dart';
import '../../tokens/app_spacing.dart';

/// Visual treatment of an [AppCard]. See docs/08_COMPONENT_LIBRARY.md §2.
enum AppCardVariant {
  /// Shadow-based depth, no border - the default choice.
  elevated,

  /// Flat with a hairline border, no shadow.
  outlined,

  /// No border, no shadow - blends into the surrounding surface.
  flat,
}

/// The platform's generic elevated/outlined container, per
/// docs/08_COMPONENT_LIBRARY.md §2 (`AppCard`) - the base every other card
/// in the library builds on (`AppKpiCard`, `AppAddressCard`, and, once their
/// owning features exist, `ProductCard`/`OrderCard`/`PaymentMethodCard`/
/// `PromotionCard`).
///
/// ```dart
/// AppCard(
///   variant: AppCardVariant.outlined,
///   onTap: () => router.go('/orders/$orderId'),
///   child: OrderSummaryContent(order: order),
/// );
/// ```
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.variant = AppCardVariant.elevated,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    super.key,
  });

  final Widget child;
  final AppCardVariant variant;

  /// When non-null, the whole card becomes tappable and renders a pressed
  /// state via `InkWell`.
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final semantic = context.semanticColors;

    final decoration = BoxDecoration(
      color: colorScheme.surface,
      borderRadius: AppRadii.borderRadiusMd,
      border: variant == AppCardVariant.outlined
          ? Border.all(color: semantic.border)
          : null,
      boxShadow: variant == AppCardVariant.elevated
          ? [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.08),
                blurRadius: AppElevation.medium,
                offset: const Offset(0, 1),
              ),
            ]
          : null,
    );

    final content = Padding(padding: padding, child: child);

    return Material(
      color: Colors.transparent,
      borderRadius: AppRadii.borderRadiusMd,
      child: Ink(
        decoration: decoration,
        child: onTap == null
            ? content
            : InkWell(
                onTap: onTap,
                borderRadius: AppRadii.borderRadiusMd,
                child: content,
              ),
      ),
    );
  }
}
