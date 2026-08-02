import '../../domain/entities/category.dart';
import '../../domain/entities/category_detail.dart';

/// Remote contract for category tree reads (mock today, Firebase later).
abstract interface class CategoriesRemoteDataSource {
  Future<List<Category>> fetchCategoryTree();

  Future<CategoryDetail> fetchCategoryDetail(String categoryId);
}
