import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/category.dart';
import '../cubit/category_tree_cubit.dart';
import '../routing/category_routes.dart';
import '../widgets/category_breadcrumb.dart';
import '../widgets/category_grid_tile.dart';

/// Visual entry point into the category tree (shell Categories tab).
class CategoryBrowseScreen extends StatelessWidget {
  const CategoryBrowseScreen({super.key, this.treeCubit});

  /// Optional override for tests; defaults to `getIt<CategoryTreeCubit>()`.
  final CategoryTreeCubit? treeCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => (treeCubit ?? getIt<CategoryTreeCubit>())..load(),
      child: const _CategoryBrowseView(),
    );
  }
}

class _CategoryBrowseView extends StatelessWidget {
  const _CategoryBrowseView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: BlocBuilder<CategoryTreeCubit, CategoryTreeState>(
        builder: (context, state) {
          return switch (state) {
            CategoryTreeInitial() ||
            CategoryTreeLoading() => const _CategoryBrowseSkeleton(),
            CategoryTreeError(:final message) => AppErrorState(
              title: 'Could not load categories',
              message: message,
              onRetry: () => context.read<CategoryTreeCubit>().retry(),
            ),
            CategoryTreeLoaded(:final visibleCategories, :final focusPath) =>
              visibleCategories.isEmpty
                  ? AppEmptyState(
                      title: focusPath.isEmpty
                          ? 'No categories yet'
                          : 'No subcategories',
                      message: focusPath.isEmpty
                          ? 'Categories will appear here once the catalog '
                                'is configured.'
                          : 'This category has no further subcategories.',
                      ctaLabel: focusPath.isEmpty ? null : 'View products',
                      onCtaPressed: focusPath.isEmpty
                          ? null
                          : () => context.push(
                              CategoryRoutes.detailPath(focusPath.last.id),
                            ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (focusPath.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.md,
                              AppSpacing.sm,
                              AppSpacing.md,
                              AppSpacing.sm,
                            ),
                            child: CategoryBreadcrumb(
                              path: focusPath,
                              includeAllRoot: true,
                              onAllTap: () =>
                                  context.read<CategoryTreeCubit>().goToRoot(),
                              onCategoryTap: (category) {
                                final index = focusPath.indexWhere(
                                  (c) => c.id == category.id,
                                );
                                context
                                    .read<CategoryTreeCubit>()
                                    .jumpToAncestor(index);
                              },
                            ),
                          ),
                        if (focusPath.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.md,
                              0,
                              AppSpacing.md,
                              AppSpacing.sm,
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton(
                                onPressed: () => context.push(
                                  CategoryRoutes.detailPath(focusPath.last.id),
                                ),
                                child: Text('Shop ${focusPath.last.name}'),
                              ),
                            ),
                          ),
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final width = constraints.maxWidth;
                              final crossAxisCount = width >= 900
                                  ? 4
                                  : width >= 600
                                  ? 3
                                  : 2;
                              return GridView.builder(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: crossAxisCount,
                                      mainAxisSpacing: AppSpacing.sm,
                                      crossAxisSpacing: AppSpacing.sm,
                                      childAspectRatio: 0.85,
                                    ),
                                itemCount: visibleCategories.length,
                                itemBuilder: (context, index) {
                                  final category = visibleCategories[index];
                                  return CategoryGridTile(
                                    category: category,
                                    onTap: () => _openDetail(context, category),
                                    onDrillDown: category.hasChildren
                                        ? () => context
                                              .read<CategoryTreeCubit>()
                                              .drillInto(category.id)
                                        : null,
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
          };
        },
      ),
    );
  }

  void _openDetail(BuildContext context, Category category) {
    context.push(CategoryRoutes.detailPath(category.id));
  }
}

class _CategoryBrowseSkeleton extends StatelessWidget {
  const _CategoryBrowseSkeleton();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        childAspectRatio: 0.85,
      ),
      itemCount: 6,
      itemBuilder: (_, _) => const AppShimmerPlaceholder(
        variant: AppShimmerVariant.card,
        height: double.infinity,
      ),
    );
  }
}
