import 'package:core/core.dart';

import '../entities/category.dart';
import '../repositories/category_repository.dart';

final class GetCategoryTree extends UseCase<List<Category>, NoParams> {
  const GetCategoryTree(this._repository);

  final CategoryRepository _repository;

  @override
  Future<Result<Failure, List<Category>>> call(NoParams params) {
    return _repository.getCategoryTree();
  }
}
