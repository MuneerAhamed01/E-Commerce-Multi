import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

import '../entities/category_detail.dart';
import '../repositories/category_repository.dart';

final class GetCategoryDetail
    extends UseCase<CategoryDetail, GetCategoryDetailParams> {
  const GetCategoryDetail(this._repository);

  final CategoryRepository _repository;

  @override
  Future<Result<Failure, CategoryDetail>> call(GetCategoryDetailParams params) {
    return _repository.getCategoryDetail(params.categoryId);
  }
}

final class GetCategoryDetailParams extends Equatable {
  const GetCategoryDetailParams(this.categoryId);

  final String categoryId;

  @override
  List<Object?> get props => [categoryId];
}
