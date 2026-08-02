/// Let authenticated users bookmark products for later.
///
/// Only symbols exported here are a public contract other packages may depend
/// on (docs/02_PROJECT_STRUCTURE.md §6 / §11).
///
/// **Circular-dep note:** `wishlist` depends on `products` for [Product]
/// display entities. `products` does **not** depend on `wishlist` — toggle
/// integration uses optional `wishlistAction` / `wishlistActionBuilder` slots
/// on product widgets/screens, composed by the storefront.
library;

export 'src/domain/entities/wishlist_item.dart';
export 'src/domain/repositories/wishlist_repository.dart';
export 'src/domain/usecases/add_to_wishlist.dart';
export 'src/domain/usecases/get_wishlist.dart';
export 'src/domain/usecases/is_in_wishlist.dart';
export 'src/domain/usecases/remove_from_wishlist.dart';
export 'src/injection/wishlist_injection.dart';
export 'src/presentation/cubit/wishlist_cubit.dart';
export 'src/presentation/cubit/wishlist_state.dart';
export 'src/presentation/routing/wishlist_routes.dart';
export 'src/presentation/screens/wishlist_screen.dart';
export 'src/presentation/widgets/wishlist_grid.dart';
export 'src/presentation/widgets/wishlist_toggle_button.dart';
