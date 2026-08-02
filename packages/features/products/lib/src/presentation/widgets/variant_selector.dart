import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/product_variant.dart';

/// Chip-style variant picker; OOS variants remain selectable.
class VariantSelector extends StatelessWidget {
  const VariantSelector({
    required this.variants,
    required this.selectedVariantId,
    required this.onSelected,
    super.key,
  });

  final List<ProductVariant> variants;
  final String selectedVariantId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Options', style: textTheme.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            for (final variant in variants)
              ChoiceChip(
                label: Text(
                  variant.isInStock ? variant.label : '${variant.label} (OOS)',
                ),
                selected: variant.id == selectedVariantId,
                onSelected: (_) => onSelected(variant.id),
                selectedColor: colorScheme.primaryContainer,
                labelStyle: textTheme.labelLarge?.copyWith(
                  color: variant.id == selectedVariantId
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurface,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
