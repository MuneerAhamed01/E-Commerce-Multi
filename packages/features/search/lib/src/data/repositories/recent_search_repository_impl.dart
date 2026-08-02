import 'package:core/core.dart';

import '../../domain/repositories/recent_search_repository.dart';
import '../datasources/recent_search_local_data_source.dart';

final class RecentSearchRepositoryImpl implements RecentSearchRepository {
  RecentSearchRepositoryImpl({required this.local});

  final RecentSearchLocalDataSource local;

  @override
  Future<Result<Failure, List<String>>> getRecentSearches() {
    return _guard(local.readRecent);
  }

  @override
  Future<Result<Failure, void>> saveRecentSearch(String query) {
    return _guard(() async {
      final trimmed = query.trim();
      if (trimmed.isEmpty) {
        return;
      }
      final existing = await local.readRecent();
      final next = <String>[
        trimmed,
        ...existing.where(
          (term) => term.toLowerCase() != trimmed.toLowerCase(),
        ),
      ];
      await local.writeRecent(next);
    });
  }

  @override
  Future<Result<Failure, void>> clearRecentSearches() {
    return _guard(local.clear);
  }

  Future<Result<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Result.success(await action());
    } on CacheException catch (e) {
      return Result.failure(CacheFailure(message: e.message));
    } on AppException catch (e) {
      return Result.failure(UnknownFailure(message: e.message));
    } on Object catch (e) {
      return Result.failure(UnknownFailure(message: e.toString()));
    }
  }
}
