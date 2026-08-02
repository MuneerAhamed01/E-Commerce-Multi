import 'package:flutter/material.dart';

import '../../theme/theme_extensions.dart';
import '../../tokens/app_radii.dart';
import '../../tokens/app_spacing.dart';
import '../cards/app_card.dart';
import 'chart_models.dart';

/// Bar orientation of an [AppBarChartCard]. See
/// docs/08_COMPONENT_LIBRARY.md §16.
enum AppBarChartDirection { vertical, horizontal }

/// A categorical comparison visualization card, per
/// docs/08_COMPONENT_LIBRARY.md §16 (`BarChartCard`). Used on Analytics
/// Detail and Reports.
///
/// Bars are proportionally sized `Container`s rather than a
/// `CustomPainter`, keeping this simple and easy to reason about for
/// discrete category comparisons (unlike the continuous trend line in
/// [AppLineChartCard]).
///
/// ```dart
/// AppBarChartCard(
///   title: 'Orders by Status',
///   data: const [AppChartDatum(label: 'Processing', value: 42), AppChartDatum(label: 'Shipped', value: 108)],
/// );
/// ```
class AppBarChartCard extends StatelessWidget {
  const AppBarChartCard({
    required this.title,
    required this.data,
    this.direction = AppBarChartDirection.vertical,
    super.key,
  });

  final String title;
  final List<AppChartDatum> data;
  final AppBarChartDirection direction;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final semantic = context.semanticColors;
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          if (data.isEmpty)
            Text(
              'No data available',
              style: textTheme.bodyMedium?.copyWith(
                color: semantic.disabledForeground,
              ),
            )
          else
            direction == AppBarChartDirection.vertical
                ? _VerticalBars(data: data, color: colorScheme.primary)
                : _HorizontalBars(data: data, color: colorScheme.primary),
        ],
      ),
    );
  }
}

class _VerticalBars extends StatelessWidget {
  const _VerticalBars({required this.data, required this.color});

  final List<AppChartDatum> data;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final maxValue = data.map((d) => d.value).reduce((a, b) => a > b ? a : b);
    final safeMax = maxValue == 0 ? 1 : maxValue;

    return SizedBox(
      height: 140,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final datum in data)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      datum.value.toStringAsFixed(0),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Container(
                      height: 100 * (datum.value / safeMax),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(AppRadii.xs),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      datum.label,
                      style: Theme.of(context).textTheme.labelSmall,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HorizontalBars extends StatelessWidget {
  const _HorizontalBars({required this.data, required this.color});

  final List<AppChartDatum> data;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final maxValue = data.map((d) => d.value).reduce((a, b) => a > b ? a : b);
    final safeMax = maxValue == 0 ? 1 : maxValue;

    return Column(
      children: [
        for (final datum in data)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  child: Text(
                    datum.label,
                    style: Theme.of(context).textTheme.labelSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: (datum.value / safeMax).clamp(0.0, 1.0),
                    child: Container(
                      height: 16,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: AppRadii.borderRadiusXs,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  datum.value.toStringAsFixed(0),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
