import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/product_image.dart';

/// Simple product image gallery (mock URLs show a branded placeholder).
class ProductGallery extends StatelessWidget {
  const ProductGallery({required this.images, this.highlightedUrl, super.key});

  final List<ProductImage> images;
  final String? highlightedUrl;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final sorted = [...images]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final activeUrl =
        highlightedUrl ?? (sorted.isNotEmpty ? sorted.first.url : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AspectRatio(
          aspectRatio: 1.1,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.image_outlined,
                    size: 48,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  if (activeUrl != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      child: Text(
                        activeUrl,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        if (sorted.length > 1) ...[
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 64,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: sorted.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
              itemBuilder: (context, index) {
                final image = sorted[index];
                final selected = image.url == activeUrl;
                return Container(
                  width: 64,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                    border: Border.all(
                      color: selected
                          ? colorScheme.primary
                          : colorScheme.outlineVariant,
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: Icon(
                    Icons.photo_outlined,
                    color: colorScheme.onSurfaceVariant,
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
