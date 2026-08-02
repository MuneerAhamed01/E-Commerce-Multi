import 'package:core/core.dart';

import '../repositories/recent_search_repository.dart';

final class GetRecentSearches extends UseCase<List<String>, NoParams> {
  const GetRecentSearches(this._repository);

  final RecentSearchRepository _repository;

  @override
  Future<Result<Failure, List<String>>> call(NoParams params) {
    return _repository.getRecentSearches();
  }
}
