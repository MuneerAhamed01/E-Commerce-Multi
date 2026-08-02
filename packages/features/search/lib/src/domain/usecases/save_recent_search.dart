import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

import '../repositories/recent_search_repository.dart';

final class SaveRecentSearch extends UseCase<void, SaveRecentSearchParams> {
  const SaveRecentSearch(this._repository);

  final RecentSearchRepository _repository;

  @override
  Future<Result<Failure, void>> call(SaveRecentSearchParams params) {
    return _repository.saveRecentSearch(params.query);
  }
}

final class SaveRecentSearchParams extends Equatable {
  const SaveRecentSearchParams(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}
