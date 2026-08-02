import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/featured_category.dart';

/// Horizontal row of featured category chips/tiles.
class FeaturedCategoryRow extends StatelessWidget {
  const FeaturedCategoryRow({
    required this.categories,
    required this.onCategoryTap,
    super.key,
  });

  final List<FeaturedCategory> categories;
  final ValueChanged<FeaturedCategory> onCategoryTap;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Shop by category', style: textTheme.titleMedium),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              final category = categories[index];
              return InkWell(
                onTap: () => onCategoryTap(category),
                borderRadius: BorderRadius.circular(AppRadii.md),
                child: SizedBox(
                  width: 88,
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: colorScheme.secondaryContainer,
                        child: Text(
                          category.name.isEmpty
                              ? '?'
                              : category.name[0].toUpperCase(),
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        category.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: textTheme.labelMedium,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
