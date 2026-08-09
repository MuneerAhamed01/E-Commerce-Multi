/// Convert a valid, non-empty cart into a placed order.
///
/// Only symbols exported here are a public contract other packages may depend
/// on (docs/02_PROJECT_STRUCTURE.md §6 / §11).
///
/// **Circular-dep note:** `checkout` → `cart` and `checkout` → `orders`.
/// `cart` does **not** depend on `checkout` — navigation to checkout is
/// composed by the storefront (or a path string in cart UI).
///
/// **Deviations:**
/// - Address book lives in checkout (`checkout.addresses.<userId>`) until
///   Phase 18 Profile.
/// - Payment methods live in checkout until Phase 16 Payments.
library;

export 'src/domain/entities/checkout_payment_method.dart';
export 'src/domain/entities/checkout_session.dart';
export 'src/domain/entities/saved_address.dart';
export 'src/domain/entities/shipping_method.dart';
export 'src/domain/repositories/checkout_repository.dart';
export 'src/domain/usecases/calculate_shipping_cost.dart';
export 'src/domain/usecases/get_checkout_payment_methods.dart';
export 'src/domain/usecases/get_saved_addresses.dart';
export 'src/domain/usecases/get_shipping_methods.dart';
export 'src/domain/usecases/place_order.dart';
export 'src/domain/usecases/save_address.dart';
export 'src/injection/checkout_injection.dart';
export 'src/presentation/bloc/checkout_bloc.dart';
export 'src/presentation/bloc/checkout_event.dart';
export 'src/presentation/bloc/checkout_state.dart';
export 'src/presentation/routing/checkout_routes.dart';
export 'src/presentation/screens/checkout_address_screen.dart';
export 'src/presentation/screens/checkout_confirmation_screen.dart';
export 'src/presentation/screens/checkout_review_screen.dart';
export 'src/presentation/screens/checkout_shipping_payment_screen.dart';
export 'src/presentation/widgets/checkout_wizard_scope.dart';
