import 'package:equatable/equatable.dart';

/// Kind of type-ahead suggestion shown on the Search entry screen.
enum SearchSuggestionKind { product, category, queryCompletion }

/// A single suggestion row mapped to design_system's
/// [AppSearchSuggestionTile] at the presentation boundary.
final class SearchSuggestion extends Equatable {
  const SearchSuggestion({
    required this.id,
    required this.title,
    required this.kind,
    this.subtitle,
    this.productId,
    this.queryText,
  });

  final String id;
  final String title;
  final SearchSuggestionKind kind;
  final String? subtitle;

  /// When [kind] is product, tapping may navigate to detail.
  final String? productId;

  /// Query string to submit when the suggestion is selected.
  final String? queryText;

  String get submitText => queryText ?? title;

  @override
  List<Object?> get props => [id, title, kind, subtitle, productId, queryText];
}
