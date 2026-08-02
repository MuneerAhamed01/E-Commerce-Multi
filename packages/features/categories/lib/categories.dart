/// Structured, hierarchical browsing entry point into Products.
///
/// Only symbols exported here are a public contract other packages may depend
/// on (docs/02_PROJECT_STRUCTURE.md §6 / §11).
library;

export 'src/domain/entities/category.dart';
export 'src/domain/entities/category_detail.dart';
export 'src/domain/repositories/category_repository.dart';
export 'src/domain/usecases/get_category_detail.dart';
export 'src/domain/usecases/get_category_tree.dart';
export 'src/injection/categories_injection.dart';
export 'src/presentation/cubit/category_detail_cubit.dart';
export 'src/presentation/cubit/category_tree_cubit.dart';
export 'src/presentation/routing/category_routes.dart';
export 'src/presentation/screens/category_browse_screen.dart';
export 'src/presentation/screens/category_detail_screen.dart';
export 'src/presentation/widgets/category_breadcrumb.dart';
export 'src/presentation/widgets/category_grid_tile.dart';
export 'src/presentation/widgets/subcategory_chip_row.dart';
