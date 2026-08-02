import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/category.dart';
import '../../domain/usecases/get_category_tree.dart';

part 'category_tree_state.dart';

/// Loads the category forest and supports in-place drill-down on Browse.
final class CategoryTreeCubit extends Cubit<CategoryTreeState> {
  CategoryTreeCubit({required this.getCategoryTree})
    : super(const CategoryTreeInitial());

  final GetCategoryTree getCategoryTree;

  List<Category> _roots = const [];
  List<Category> _focusPath = const [];

  Future<void> load() async {
    emit(const CategoryTreeLoading());
    final result = await getCategoryTree(const NoParams());
    result.fold(
      onFailure: (failure) => emit(CategoryTreeError(_mapFailure(failure))),
      onSuccess: (roots) {
        _roots = roots;
        _focusPath = const [];
        emit(_loadedState());
      },
    );
  }

  Future<void> retry() => load();

  /// Drill into [categoryId] when it has children (in-place browse).
  void drillInto(String categoryId) {
    final current = state;
    if (current is! CategoryTreeLoaded) {
      return;
    }
    final category = _findInVisibleOrTree(categoryId);
    if (category == null || !category.hasChildren) {
      return;
    }
    _focusPath = [..._focusPath, category.copyWith(children: const [])];
    emit(_loadedState());
  }

  /// Jump to ancestor at [index] in [CategoryTreeLoaded.focusPath], or roots.
  void jumpToAncestor(int index) {
    final current = state;
    if (current is! CategoryTreeLoaded) {
      return;
    }
    if (index < 0) {
      _focusPath = const [];
    } else if (index < _focusPath.length) {
      _focusPath = _focusPath.sublist(0, index + 1);
    }
    emit(_loadedState());
  }

  void goToRoot() {
    _focusPath = const [];
    if (state is CategoryTreeLoaded) {
      emit(_loadedState());
    }
  }

  CategoryTreeLoaded _loadedState() {
    final visible = _focusPath.isEmpty
        ? _roots
        : _resolveFocusChildren(_focusPath.last.id) ?? const <Category>[];
    return CategoryTreeLoaded(
      roots: _roots,
      visibleCategories: visible,
      focusPath: _focusPath,
    );
  }

  List<Category>? _resolveFocusChildren(String focusId) {
    for (final root in _roots) {
      final node = root.findById(focusId);
      if (node != null) {
        return node.children;
      }
    }
    return null;
  }

  Category? _findInVisibleOrTree(String categoryId) {
    final current = state;
    if (current is CategoryTreeLoaded) {
      for (final c in current.visibleCategories) {
        if (c.id == categoryId) {
          return c;
        }
      }
    }
    for (final root in _roots) {
      final found = root.findById(categoryId);
      if (found != null) {
        return found;
      }
    }
    return null;
  }

  String _mapFailure(Failure failure) {
    return failure.message ?? 'Something went wrong. Please try again.';
  }
}
