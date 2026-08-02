import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/category.dart';

/// Grid tile for a browse-level category.
class CategoryGridTile extends StatelessWidget {
  const CategoryGridTile({
    required this.category,
    required this.onTap,
    this.onDrillDown,
    super.key,
  });

  final Category category;
  final VoidCallback onTap;

  /// Optional secondary action when [category] has children (in-place drill).
  final VoidCallback? onDrillDown;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: ColoredBox(
                    color: colorScheme.surfaceContainerHigh,
                    child: Center(
                      child: Icon(
                        Icons.category_outlined,
                        size: 40,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                category.name,
                style: textTheme.titleSmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (category.hasChildren) ...[
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${category.children.length} subcategories',
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    if (onDrillDown != null)
                      IconButton(
                        tooltip: 'Browse subcategories',
                        onPressed: onDrillDown,
                        icon: const Icon(Icons.subdirectory_arrow_right),
                        visualDensity: VisualDensity.compact,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
