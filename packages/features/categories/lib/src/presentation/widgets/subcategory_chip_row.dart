import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/category.dart';

/// Horizontal chip row for navigating to child categories.
class SubcategoryChipRow extends StatelessWidget {
  const SubcategoryChipRow({
    required this.subcategories,
    required this.onSubcategoryTap,
    super.key,
  });

  final List<Category> subcategories;
  final ValueChanged<Category> onSubcategoryTap;

  @override
  Widget build(BuildContext context) {
    if (subcategories.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: subcategories.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final category = subcategories[index];
          return ActionChip(
            label: Text(category.name),
            onPressed: () => onSubcategoryTap(category),
          );
        },
      ),
    );
  }
}
