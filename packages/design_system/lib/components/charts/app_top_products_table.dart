import 'package:flutter/material.dart';

import '../../theme/theme_extensions.dart';
import '../../tokens/app_spacing.dart';
import '../cards/app_card.dart';
import 'chart_models.dart';

/// A ranked mini-table, chart-adjacent, per docs/08_COMPONENT_LIBRARY.md
/// §16 (`TopProductsTable`). Used on the Admin Dashboard.
///
/// Takes plain [AppChartDatum] entries (label + value) rather than a
/// `Product` aggregate, since the Products domain doesn't exist yet
/// relative to this package (docs/03_DEVELOPMENT_PHASES.md Phase 9) - the
/// owning feature maps its "top products by revenue/units" query result
/// into this shape at the presentation boundary. [valueLabel] captions
/// what [AppChartDatum.value] represents (e.g. `'Units Sold'`).
///
/// ```dart
/// AppTopProductsTable(
///   title: 'Top Products',
///   valueLabel: 'Units Sold',
///   items: const [AppChartDatum(label: 'Running Shoes', value: 128)],
/// );
/// ```
class AppTopProductsTable extends StatelessWidget {
  const AppTopProductsTable({
    required this.title,
    required this.items,
    this.valueLabel = 'Value',
    super.key,
  });

  final String title;
  final List<AppChartDatum> items;
  final String valueLabel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final semantic = context.semanticColors;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          if (items.isEmpty)
            Text(
              'No data available',
              style: textTheme.bodyMedium?.copyWith(
                color: semantic.disabledForeground,
              ),
            )
          else
            for (var i = 0; i < items.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      child: Text('${i + 1}', style: textTheme.labelMedium),
                    ),
                    Expanded(
                      child: Text(items[i].label, style: textTheme.bodyMedium),
                    ),
                    Text(
                      items[i].value.toStringAsFixed(0),
                      style: textTheme.labelLarge,
                    ),
                  ],
                ),
              ),
          if (items.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              valueLabel,
              style: textTheme.labelSmall?.copyWith(
                color: semantic.disabledForeground,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
