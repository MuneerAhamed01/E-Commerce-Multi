import 'package:core/core.dart';

import '../repositories/recent_search_repository.dart';

final class ClearRecentSearches extends UseCase<void, NoParams> {
  const ClearRecentSearches(this._repository);

  final RecentSearchRepository _repository;

  @override
  Future<Result<Failure, void>> call(NoParams params) {
    return _repository.clearRecentSearches();
  }
}
