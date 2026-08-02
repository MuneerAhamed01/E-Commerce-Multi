import 'package:flutter/material.dart';

import '../../theme/theme_extensions.dart';
import '../../tokens/app_spacing.dart';
import '../states/shimmer_placeholder.dart';
import 'app_card.dart';

/// Trend direction for the delta shown on an [AppKpiCard]. See
/// docs/08_COMPONENT_LIBRARY.md §2.
enum AppKpiTrend { positive, negative, neutral }

/// A single metric display for dashboards, per
/// docs/08_COMPONENT_LIBRARY.md §2 (`KpiCard`). Deliberately takes plain
/// `label`/`value` strings rather than a domain aggregate type, since the
/// Admin Dashboard/Analytics domain doesn't exist yet
/// (docs/03_DEVELOPMENT_PHASES.md Phase 8/22) - the owning feature formats
/// its aggregation result into these primitives at the presentation
/// boundary.
///
/// ```dart
/// AppKpiCard(
///   label: 'Total Sales',
///   value: r'$12,480',
///   deltaPercent: 4.2,
///   trend: AppKpiTrend.positive,
///   icon: Icons.trending_up,
/// );
/// ```
class AppKpiCard extends StatelessWidget {
  const AppKpiCard({
    required this.label,
    required this.value,
    this.deltaPercent,
    this.trend = AppKpiTrend.neutral,
    this.icon,
    this.isLoading = false,
    super.key,
  });

  final String label;
  final String value;

  /// Percentage change vs. the prior comparison period, e.g. `4.2` for
  /// "+4.2%". Sign is derived from [trend], not from this value's sign.
  final double? deltaPercent;

  final AppKpiTrend trend;
  final IconData? icon;

  /// When `true`, renders a shimmer skeleton instead of [value]/[deltaPercent].
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AppShimmerPlaceholder(width: 96, height: 12),
            SizedBox(height: AppSpacing.sm),
            AppShimmerPlaceholder(width: 72, height: 24),
          ],
        ),
      );
    }

    final semantic = context.semanticColors;
    final textTheme = Theme.of(context).textTheme;
    final (deltaColor, deltaIcon) = switch (trend) {
      AppKpiTrend.positive => (semantic.success, Icons.arrow_upward),
      AppKpiTrend.negative => (
        Theme.of(context).colorScheme.error,
        Icons.arrow_downward,
      ),
      AppKpiTrend.neutral => (textTheme.bodySmall?.color, null),
    };

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: textTheme.bodyMedium)),
              if (icon != null)
                Icon(icon, size: 18, color: textTheme.bodySmall?.color),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(value, style: textTheme.headlineSmall),
          if (deltaPercent != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (deltaIcon != null)
                  Icon(deltaIcon, size: 14, color: deltaColor),
                Text(
                  '${deltaPercent!.abs().toStringAsFixed(1)}%',
                  style: textTheme.labelMedium?.copyWith(color: deltaColor),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
