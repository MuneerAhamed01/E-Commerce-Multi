import 'package:flutter/material.dart';

import '../../theme/theme_extensions.dart';
import '../../tokens/app_spacing.dart';
import '../cards/app_card.dart';
import 'chart_models.dart';

/// A trend-over-time visualization card, per docs/08_COMPONENT_LIBRARY.md
/// §16 (`LineChartCard`). Used on the Admin Dashboard and Analytics Detail.
///
/// Renders via a lightweight [CustomPainter] rather than a third-party
/// charting package, keeping this package's dependency surface minimal
/// (`design_system` depends only on `core` and Flutter - see
/// docs/02_PROJECT_STRUCTURE.md §5).
///
/// Degrades to a centered message when [series] is empty or every series
/// has zero data points, per docs/03_DEVELOPMENT_PHASES.md Phase 22 review
/// checklist ("charts degrade gracefully to empty state with zero data").
///
/// ```dart
/// AppLineChartCard(
///   title: 'Sales (Last 7 Days)',
///   xLabels: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
///   series: [AppChartSeries(label: 'Revenue', values: dailyRevenue)],
/// );
/// ```
class AppLineChartCard extends StatelessWidget {
  const AppLineChartCard({
    required this.title,
    required this.series,
    this.xLabels = const [],
    this.height = 180,
    super.key,
  });

  final String title;
  final List<AppChartSeries> series;
  final List<String> xLabels;
  final double height;

  bool get _hasData => series.any((s) => s.values.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final semantic = context.semanticColors;

    final palette = [
      colorScheme.primary,
      colorScheme.secondary,
      semantic.success,
      semantic.warning,
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          if (!_hasData)
            SizedBox(
              height: height,
              child: Center(
                child: Text(
                  'No data available',
                  style: textTheme.bodyMedium?.copyWith(
                    color: semantic.disabledForeground,
                  ),
                ),
              ),
            )
          else
            SizedBox(
              height: height,
              width: double.infinity,
              child: CustomPaint(
                painter: _LineChartPainter(
                  series: series,
                  colors: palette,
                  gridColor: semantic.border,
                ),
              ),
            ),
          if (series.length > 1) ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.md,
              children: [
                for (var i = 0; i < series.length; i++)
                  _LegendEntry(
                    color: palette[i % palette.length],
                    label: series[i].label,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _LegendEntry extends StatelessWidget {
  const _LegendEntry({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({
    required this.series,
    required this.colors,
    required this.gridColor,
  });

  final List<AppChartSeries> series;
  final List<Color> colors;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (var i = 0; i <= 3; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final allValues = series.expand((s) => s.values).toList();
    if (allValues.isEmpty) {
      return;
    }
    final maxValue = allValues.reduce((a, b) => a > b ? a : b);
    final minValue = allValues.reduce((a, b) => a < b ? a : b);
    final range = (maxValue - minValue) == 0 ? 1 : maxValue - minValue;

    for (var s = 0; s < series.length; s++) {
      final values = series[s].values;
      if (values.length < 2) {
        continue;
      }
      final path = Path();
      for (var i = 0; i < values.length; i++) {
        final x = size.width * i / (values.length - 1);
        final normalized = (values[i] - minValue) / range;
        final y = size.height - (normalized * size.height);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      final linePaint = Paint()
        ..color = colors[s % colors.length]
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(path, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.series != series || oldDelegate.colors != colors;
  }
}
