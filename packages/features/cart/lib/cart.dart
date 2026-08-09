/// Hold items intended for purchase; compute authoritative pricing; apply promo codes.
///
/// Only symbols exported here are a public contract other packages may depend
/// on (docs/02_PROJECT_STRUCTURE.md §6 / §11).
///
/// **Circular-dep note:** `cart` depends on `products` for price/stock via
/// [GetProductDetail]. `products` does **not** depend on `cart` — add-to-cart
/// is composed by the storefront via optional `onAddToCart` on product detail.
///
/// **Marketing deviation:** promo codes are validated locally in cart until
/// Phase 25 Marketing owns coupons (`ValidateCoupon`).
library;

export 'src/domain/entities/cart.dart';
export 'src/domain/entities/cart_item.dart';
export 'src/domain/entities/pricing_breakdown.dart';
export 'src/domain/entities/promo_definition.dart';
export 'src/domain/pricing/cart_pricing_engine.dart';
export 'src/domain/promo/cart_promo_catalog.dart';
export 'src/domain/repositories/cart_repository.dart';
export 'src/domain/usecases/add_to_cart.dart';
export 'src/domain/usecases/apply_promo_code.dart';
export 'src/domain/usecases/clear_cart.dart';
export 'src/domain/usecases/get_cart.dart';
export 'src/domain/usecases/get_cart_summary.dart';
export 'src/domain/usecases/remove_from_cart.dart';
export 'src/domain/usecases/remove_promo_code.dart';
export 'src/domain/usecases/update_cart_item_quantity.dart';
export 'src/injection/cart_injection.dart';
export 'src/presentation/bloc/cart_bloc.dart';
export 'src/presentation/bloc/cart_event.dart';
export 'src/presentation/bloc/cart_state.dart';
export 'src/presentation/routing/cart_routes.dart';
export 'src/presentation/screens/cart_screen.dart';
export 'src/presentation/widgets/cart_badge.dart';
export 'src/presentation/widgets/cart_line_item.dart';
export 'src/presentation/widgets/cart_summary_panel.dart';
