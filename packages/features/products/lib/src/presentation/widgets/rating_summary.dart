import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Aggregate rating header above the review list.
class RatingSummary extends StatelessWidget {
  const RatingSummary({
    required this.averageRating,
    required this.reviewCount,
    super.key,
  });

  final double averageRating;
  final int reviewCount;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(Icons.star_rounded, color: colorScheme.tertiary),
        const SizedBox(width: AppSpacing.xs),
        Text(averageRating.toStringAsFixed(1), style: textTheme.titleMedium),
        const SizedBox(width: AppSpacing.sm),
        Text(
          reviewCount == 1 ? '1 review' : '$reviewCount reviews',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
