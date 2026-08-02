import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/theme_extensions.dart';
import '../../tokens/app_spacing.dart';
import '../cards/app_card.dart';
import 'chart_models.dart';

/// A proportional breakdown visualization card, per
/// docs/08_COMPONENT_LIBRARY.md §16 (`DonutChartCard`). Used on the Admin
/// Dashboard (e.g. order status distribution).
///
/// ```dart
/// AppDonutChartCard(
///   title: 'Orders by Status',
///   segments: const [AppChartSegment(label: 'Shipped', value: 60), AppChartSegment(label: 'Processing', value: 40)],
/// );
/// ```
class AppDonutChartCard extends StatelessWidget {
  const AppDonutChartCard({
    required this.title,
    required this.segments,
    super.key,
  });

  final String title;
  final List<AppChartSegment> segments;

  bool get _hasData => segments.any((s) => s.value > 0);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final semantic = context.semanticColors;
    final colorScheme = Theme.of(context).colorScheme;
    final palette = [
      colorScheme.primary,
      colorScheme.secondary,
      semantic.success,
      semantic.warning,
      semantic.info,
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          if (!_hasData)
            Text(
              'No data available',
              style: textTheme.bodyMedium?.copyWith(
                color: semantic.disabledForeground,
              ),
            )
          else
            Row(
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CustomPaint(
                    painter: _DonutPainter(segments: segments, colors: palette),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < segments.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: palette[i % palette.length],
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                '${segments[i].label} (${segments[i].value.toStringAsFixed(0)})',
                                style: textTheme.labelSmall,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({required this.segments, required this.colors});

  final List<AppChartSegment> segments;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final total = segments.fold<double>(0, (sum, s) => sum + s.value);
    if (total <= 0) {
      return;
    }

    final rect = Offset.zero & size;
    const strokeWidth = 16.0;
    var startAngle = -math.pi / 2;

    for (var i = 0; i < segments.length; i++) {
      final sweep = (segments[i].value / total) * 2 * math.pi;
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(
        rect.deflate(strokeWidth / 2),
        startAngle,
        sweep,
        false,
        paint,
      );
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.segments != segments || oldDelegate.colors != colors;
  }
}
