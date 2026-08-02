part of 'category_tree_cubit.dart';

sealed class CategoryTreeState extends Equatable {
  const CategoryTreeState();

  @override
  List<Object?> get props => [];
}

final class CategoryTreeInitial extends CategoryTreeState {
  const CategoryTreeInitial();
}

final class CategoryTreeLoading extends CategoryTreeState {
  const CategoryTreeLoading();
}

final class CategoryTreeError extends CategoryTreeState {
  const CategoryTreeError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Loaded tree with optional in-place drill-down focus.
final class CategoryTreeLoaded extends CategoryTreeState {
  const CategoryTreeLoaded({
    required this.roots,
    required this.visibleCategories,
    this.focusPath = const [],
  });

  final List<Category> roots;

  /// Categories shown in the browse grid (roots or children of focus).
  final List<Category> visibleCategories;

  /// Root-first ancestors of the current focus (empty = showing roots).
  final List<Category> focusPath;

  Category? get focusedCategory => focusPath.isEmpty ? null : focusPath.last;

  @override
  List<Object?> get props => [roots, visibleCategories, focusPath];
}
