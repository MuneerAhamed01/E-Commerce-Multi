import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/review.dart';

/// Vertical list of product reviews.
class ReviewList extends StatelessWidget {
  const ReviewList({required this.reviews, super.key});

  final List<Review> reviews;

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return const AppEmptyState(
        title: 'No reviews yet',
        message: 'Be the first to share your experience with this product.',
      );
    }

    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        for (final review in reviews) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(review.userDisplayName, style: textTheme.titleSmall),
                    const Spacer(),
                    Icon(
                      Icons.star_rounded,
                      size: 16,
                      color: colorScheme.tertiary,
                    ),
                    const SizedBox(width: 2),
                    Text('${review.rating}', style: textTheme.labelLarge),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(review.title, style: textTheme.labelLarge),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  review.body,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}
