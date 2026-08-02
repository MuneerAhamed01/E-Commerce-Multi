/// Query-driven product discovery with filters and sort.
///
/// Only symbols exported here are a public contract other packages may depend
/// on (docs/02_PROJECT_STRUCTURE.md §6 / §11).
library;

export 'src/domain/entities/search_filter.dart';
export 'src/domain/entities/search_query.dart';
export 'src/domain/entities/search_suggestion.dart';
export 'src/domain/entities/sort_option.dart';
export 'src/domain/repositories/recent_search_repository.dart';
export 'src/domain/repositories/search_repository.dart';
export 'src/domain/usecases/clear_recent_searches.dart';
export 'src/domain/usecases/get_recent_searches.dart';
export 'src/domain/usecases/get_search_suggestions.dart';
export 'src/domain/usecases/save_recent_search.dart';
export 'src/domain/usecases/search_products.dart';
export 'src/injection/search_injection.dart';
export 'src/presentation/bloc/search_bloc.dart';
export 'src/presentation/bloc/search_results_bloc.dart';
export 'src/presentation/routing/search_routes.dart';
export 'src/presentation/screens/search_entry_screen.dart';
export 'src/presentation/screens/search_results_screen.dart';
