import 'package:core/core.dart';

import '../entities/category.dart';
import '../entities/category_detail.dart';

/// Category tree repository contract (docs/10_DATA_FLOW.md §3).
abstract interface class CategoryRepository {
  /// Full forest of root categories with nested [Category.children].
  Future<Result<Failure, List<Category>>> getCategoryTree();

  /// Single category (with direct children) plus ancestor chain.
  Future<Result<Failure, CategoryDetail>> getCategoryDetail(String categoryId);
}
