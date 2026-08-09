import 'package:authentication/authentication.dart';
import 'package:core/core.dart';
import 'package:products/products.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/datasources/cart_remote_data_source.dart';
import '../data/datasources/mock_cart_remote_data_source.dart';
import '../data/repositories/mock_cart_repository_impl.dart';
import '../domain/repositories/cart_repository.dart';
import '../domain/usecases/add_to_cart.dart';
import '../domain/usecases/apply_promo_code.dart';
import '../domain/usecases/clear_cart.dart';
import '../domain/usecases/get_cart.dart';
import '../domain/usecases/get_cart_summary.dart';
import '../domain/usecases/remove_from_cart.dart';
import '../domain/usecases/remove_promo_code.dart';
import '../domain/usecases/update_cart_item_quantity.dart';
import '../presentation/bloc/cart_bloc.dart';

/// Guest cart owner id used when unauthenticated ([TenantConfig.allowGuestCart]).
const String cartGuestOwnerId = 'guest';

/// Registers cart data/domain/presentation dependencies.
///
/// Call **after** [configureMockInjection], [configureProductsInjection], and
/// [configureAuthenticationInjection] so [MockNetworkSimulator] /
/// [GetProductDetail] / [SharedPreferences] / [AuthBloc] exist.
void configureCartInjection() {
  if (!getIt.isRegistered<MockNetworkSimulator>() ||
      !getIt.isRegistered<MockSeedStore>() ||
      !getIt.isRegistered<MockDeveloperControls>()) {
    throw StateError(
      'configureCartInjection() requires configureMockInjection() first.',
    );
  }
  if (!getIt.isRegistered<GetProductDetail>()) {
    throw StateError(
      'configureCartInjection() requires configureProductsInjection() first.',
    );
  }
  if (!getIt.isRegistered<SharedPreferences>()) {
    throw StateError(
      'configureCartInjection() requires SharedPreferences '
      '(configureAuthenticationInjection) first.',
    );
  }
  if (!getIt.isRegistered<AuthBloc>()) {
    throw StateError(
      'configureCartInjection() requires AuthBloc '
      '(configureAuthenticationInjection) first.',
    );
  }

  if (!getIt.isRegistered<CartRemoteDataSource>()) {
    getIt.registerLazySingleton<CartRemoteDataSource>(
      () => MockCartRemoteDataSource(
        simulator: getIt<MockNetworkSimulator>(),
        preferences: getIt<SharedPreferences>(),
        controls: getIt<MockDeveloperControls>(),
        getProductDetail: getIt<GetProductDetail>(),
      ),
    );
  }

  if (!getIt.isRegistered<CartRepository>()) {
    getIt.registerLazySingleton<CartRepository>(
      () => MockCartRepositoryImpl(remote: getIt()),
    );
  }

  _registerFactory<GetCart>(() => GetCart(getIt()));
  _registerFactory<GetCartSummary>(() => GetCartSummary(getIt()));
  _registerFactory<AddToCart>(() => AddToCart(getIt()));
  _registerFactory<UpdateCartItemQuantity>(
    () => UpdateCartItemQuantity(getIt()),
  );
  _registerFactory<RemoveFromCart>(() => RemoveFromCart(getIt()));
  _registerFactory<ClearCart>(() => ClearCart(getIt()));
  _registerFactory<ApplyPromoCode>(() => ApplyPromoCode(getIt()));
  _registerFactory<RemovePromoCode>(() => RemovePromoCode(getIt()));

  if (!getIt.isRegistered<CartBloc>()) {
    getIt.registerLazySingleton<CartBloc>(
      () => CartBloc(
        getCartSummary: getIt(),
        addToCart: getIt(),
        updateCartItemQuantity: getIt(),
        removeFromCart: getIt(),
        clearCart: getIt(),
        applyPromoCode: getIt(),
        removePromoCode: getIt(),
        cartRepository: getIt(),
        authBloc: getIt(),
      ),
    );
  }
}

void _registerFactory<T extends Object>(T Function() factory) {
  if (!getIt.isRegistered<T>()) {
    getIt.registerFactory<T>(factory);
  }
}
