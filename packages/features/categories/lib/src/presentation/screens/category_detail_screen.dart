import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:products/products.dart';

import '../../domain/entities/category.dart';
import '../cubit/category_detail_cubit.dart';
import '../routing/category_routes.dart';
import '../widgets/category_breadcrumb.dart';
import '../widgets/subcategory_chip_row.dart';

/// Category detail = metadata chrome + filtered [ProductListScreen].
class CategoryDetailScreen extends StatelessWidget {
  const CategoryDetailScreen({
    required this.categoryId,
    this.detailCubit,
    this.listBloc,
    super.key,
  });

  final String categoryId;

  /// Optional overrides for tests.
  final CategoryDetailCubit? detailCubit;
  final ProductListBloc? listBloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      key: ValueKey(categoryId),
      create: (_) =>
          (detailCubit ?? getIt<CategoryDetailCubit>())..load(categoryId),
      child: _CategoryDetailBody(categoryId: categoryId, listBloc: listBloc),
    );
  }
}

class _CategoryDetailBody extends StatelessWidget {
  const _CategoryDetailBody({required this.categoryId, this.listBloc});

  final String categoryId;
  final ProductListBloc? listBloc;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryDetailCubit, CategoryDetailState>(
      builder: (context, state) {
        return switch (state) {
          CategoryDetailInitial() || CategoryDetailLoading() => Scaffold(
            appBar: AppBar(title: const Text('Category')),
            body: const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  AppShimmerPlaceholder(width: 220, height: 16),
                  SizedBox(height: AppSpacing.md),
                  AppShimmerPlaceholder(width: double.infinity, height: 36),
                  SizedBox(height: AppSpacing.lg),
                  Expanded(
                    child: AppShimmerPlaceholder(
                      variant: AppShimmerVariant.card,
                      height: double.infinity,
                    ),
                  ),
                ],
              ),
            ),
          ),
          CategoryDetailError(:final message, :final isNotFound) => Scaffold(
            appBar: AppBar(title: const Text('Category')),
            body: isNotFound
                ? AppEmptyState(
                    title: 'Category not found',
                    message: message,
                    ctaLabel: 'Browse categories',
                    onCtaPressed: () => context.go(CategoryRoutes.browsePath),
                  )
                : AppErrorState(
                    title: 'Could not load category',
                    message: message,
                    onRetry: () => context.read<CategoryDetailCubit>().retry(),
                  ),
          ),
          CategoryDetailLoaded(:final detail) => ProductListScreen(
            categoryId: detail.category.id,
            title: detail.category.name,
            listBloc: listBloc,
            header: _CategoryDetailHeader(
              path: detail.path,
              subcategories: detail.category.children,
              onBreadcrumbTap: (category) =>
                  context.go(CategoryRoutes.detailPath(category.id)),
              onAllTap: () => context.go(CategoryRoutes.browsePath),
              onSubcategoryTap: (category) =>
                  context.go(CategoryRoutes.detailPath(category.id)),
            ),
          ),
        };
      },
    );
  }
}

class _CategoryDetailHeader extends StatelessWidget {
  const _CategoryDetailHeader({
    required this.path,
    required this.subcategories,
    required this.onBreadcrumbTap,
    required this.onAllTap,
    required this.onSubcategoryTap,
  });

  final List<Category> path;
  final List<Category> subcategories;
  final ValueChanged<Category> onBreadcrumbTap;
  final VoidCallback onAllTap;
  final ValueChanged<Category> onSubcategoryTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: CategoryBreadcrumb(
            path: path,
            includeAllRoot: true,
            onAllTap: onAllTap,
            onCategoryTap: onBreadcrumbTap,
          ),
        ),
        if (subcategories.isNotEmpty) ...[
          SubcategoryChipRow(
            subcategories: subcategories,
            onSubcategoryTap: onSubcategoryTap,
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}
