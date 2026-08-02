import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

import '../entities/search_suggestion.dart';
import '../repositories/search_repository.dart';

final class GetSearchSuggestions
    extends UseCase<List<SearchSuggestion>, GetSearchSuggestionsParams> {
  const GetSearchSuggestions(this._repository);

  final SearchRepository _repository;

  @override
  Future<Result<Failure, List<SearchSuggestion>>> call(
    GetSearchSuggestionsParams params,
  ) {
    return _repository.getSuggestions(params.query);
  }
}

final class GetSearchSuggestionsParams extends Equatable {
  const GetSearchSuggestionsParams(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}
