import 'package:core/core.dart';
import 'package:products/products.dart';

import '../../domain/entities/search_filter.dart';
import '../../domain/entities/search_suggestion.dart';
import '../../domain/entities/sort_option.dart';
import '../../domain/repositories/search_repository.dart';
import '../datasources/search_remote_data_source.dart';

/// Maps data-layer exceptions → [Failure].
final class MockSearchRepositoryImpl implements SearchRepository {
  MockSearchRepositoryImpl({required this.remote});

  final SearchRemoteDataSource remote;

  @override
  Future<Result<Failure, PaginatedResult<Product>>> searchProducts({
    required String query,
    required SearchFilter filter,
    required SortOption sort,
    required ProductPageRequest page,
  }) {
    return _guard(
      () => remote.searchProducts(
        query: query,
        filter: filter,
        sort: sort,
        page: page,
      ),
    );
  }

  @override
  Future<Result<Failure, List<SearchSuggestion>>> getSuggestions(String query) {
    return _guard(() => remote.fetchSuggestions(query));
  }

  @override
  Future<Result<Failure, Map<String, String>>> getCategoryFacets() {
    return _guard(remote.fetchCategoryFacets);
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
