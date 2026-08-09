import 'package:authentication/authentication.dart';
import 'package:cart/cart.dart';
import 'package:core/core.dart';
import 'package:orders/orders.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/datasources/checkout_remote_data_source.dart';
import '../data/datasources/mock_checkout_remote_data_source.dart';
import '../data/repositories/mock_checkout_repository_impl.dart';
import '../domain/repositories/checkout_repository.dart';
import '../domain/usecases/calculate_shipping_cost.dart';
import '../domain/usecases/get_checkout_payment_methods.dart';
import '../domain/usecases/get_saved_addresses.dart';
import '../domain/usecases/get_shipping_methods.dart';
import '../domain/usecases/place_order.dart';
import '../domain/usecases/save_address.dart';
import '../presentation/bloc/checkout_bloc.dart';

/// Registers checkout data/domain/presentation dependencies.
///
/// Call **after** [configureOrdersInjection], [configureCartInjection], and
/// [configureAuthenticationInjection].
void configureCheckoutInjection() {
  if (!getIt.isRegistered<MockNetworkSimulator>() ||
      !getIt.isRegistered<MockDeveloperControls>()) {
    throw StateError(
      'configureCheckoutInjection() requires configureMockInjection() first.',
    );
  }
  if (!getIt.isRegistered<SharedPreferences>()) {
    throw StateError(
      'configureCheckoutInjection() requires SharedPreferences first.',
    );
  }
  if (!getIt.isRegistered<OrderRepository>()) {
    throw StateError(
      'configureCheckoutInjection() requires configureOrdersInjection() first.',
    );
  }
  if (!getIt.isRegistered<GetCartSummary>() ||
      !getIt.isRegistered<ClearCart>()) {
    throw StateError(
      'configureCheckoutInjection() requires configureCartInjection() first.',
    );
  }
  if (!getIt.isRegistered<AuthBloc>()) {
    throw StateError('configureCheckoutInjection() requires AuthBloc first.');
  }

  if (!getIt.isRegistered<CheckoutRemoteDataSource>()) {
    getIt.registerLazySingleton<CheckoutRemoteDataSource>(
      () => MockCheckoutRemoteDataSource(
        simulator: getIt<MockNetworkSimulator>(),
        preferences: getIt<SharedPreferences>(),
        controls: getIt<MockDeveloperControls>(),
      ),
    );
  }

  if (!getIt.isRegistered<CheckoutRepository>()) {
    getIt.registerLazySingleton<CheckoutRepository>(
      () => MockCheckoutRepositoryImpl(remote: getIt()),
    );
  }

  _registerFactory<GetSavedAddresses>(() => GetSavedAddresses(getIt()));
  _registerFactory<SaveAddress>(() => SaveAddress(getIt()));
  _registerFactory<GetShippingMethods>(() => GetShippingMethods(getIt()));
  _registerFactory<CalculateShippingCost>(() => CalculateShippingCost(getIt()));
  _registerFactory<GetCheckoutPaymentMethods>(
    () => GetCheckoutPaymentMethods(getIt()),
  );
  _registerFactory<PlaceOrder>(
    () => PlaceOrder(
      getCartSummary: getIt(),
      clearCart: getIt(),
      orderRepository: getIt(),
      checkoutRepository: getIt(),
    ),
  );

  if (!getIt.isRegistered<CheckoutBloc>()) {
    getIt.registerFactory<CheckoutBloc>(
      () => CheckoutBloc(
        getSavedAddresses: getIt(),
        saveAddress: getIt(),
        getShippingMethods: getIt(),
        calculateShippingCost: getIt(),
        getCheckoutPaymentMethods: getIt(),
        getCartSummary: getIt(),
        placeOrder: getIt(),
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
