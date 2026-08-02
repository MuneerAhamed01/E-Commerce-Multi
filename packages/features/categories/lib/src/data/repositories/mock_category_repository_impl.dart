import 'package:core/core.dart';

import '../../domain/entities/category.dart';
import '../../domain/entities/category_detail.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/categories_remote_data_source.dart';

/// Maps data-layer exceptions → [Failure] (docs/10_DATA_FLOW.md §1).
final class MockCategoryRepositoryImpl implements CategoryRepository {
  MockCategoryRepositoryImpl({required this.remote});

  final CategoriesRemoteDataSource remote;

  @override
  Future<Result<Failure, List<Category>>> getCategoryTree() {
    return _guard(remote.fetchCategoryTree);
  }

  @override
  Future<Result<Failure, CategoryDetail>> getCategoryDetail(String categoryId) {
    return _guard(() => remote.fetchCategoryDetail(categoryId));
  }

  Future<Result<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Result.success(await action());
    } on ServerException catch (e) {
      return Result.failure(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    } on CacheException catch (e) {
      return Result.failure(CacheFailure(message: e.message));
    } on NetworkException catch (e) {
      return Result.failure(NetworkFailure(message: e.message));
    } on NotFoundException catch (e) {
      return Result.failure(NotFoundFailure(message: e.message));
    } on UnauthorizedException catch (e) {
      return Result.failure(UnauthorizedFailure(message: e.message));
    } on ValidationException catch (e) {
      return Result.failure(
        ValidationFailure(e.fieldErrors, message: e.message),
      );
    } on AppException catch (e) {
      return Result.failure(UnknownFailure(message: e.message));
    } on Object catch (e) {
      return Result.failure(UnknownFailure(message: e.toString()));
    }
  }
}
