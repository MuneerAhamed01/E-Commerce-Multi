import 'package:core/core.dart';

import '../../domain/entities/category.dart';
import '../../domain/entities/category_detail.dart';
import '../mock/categories_call_types.dart';
import '../mock/category_tree_builder.dart';
import 'categories_remote_data_source.dart';

/// In-memory category tree backed by [MockSeedStore].
final class MockCategoriesRemoteDataSource
    with MockDataSourceMixin
    implements CategoriesRemoteDataSource {
  MockCategoriesRemoteDataSource({
    required this.simulator,
    required MockSeedStore store,
    required MockDeveloperControls controls,
    // Private fields can't use initializing formals with public param names.
    // ignore: prefer_initializing_formals
  }) : _store = store,
       // ignore: prefer_initializing_formals
       _controls = controls {
    _rebuild();
    _controls.registerResetListener(_onReset);
  }

  @override
  final MockNetworkSimulator simulator;

  final MockSeedStore _store;
  final MockDeveloperControls _controls;

  late List<Category> _roots;

  void dispose() {
    _controls.unregisterResetListener(_onReset);
  }

  void _onReset() {
    _rebuild();
  }

  void _rebuild() {
    _roots = CategoryTreeBuilder.buildTree(_store.categories);
  }

  @override
  Future<List<Category>> fetchCategoryTree() {
    return guarded(CategoriesCallTypes.tree, () async => _roots);
  }

  @override
  Future<CategoryDetail> fetchCategoryDetail(String categoryId) {
    return guarded(CategoriesCallTypes.detail, () async {
      final detail = CategoryTreeBuilder.detailFor(_roots, categoryId);
      if (detail == null) {
        throw NotFoundException('Category $categoryId not found');
      }
      return detail;
    });
  }
}
