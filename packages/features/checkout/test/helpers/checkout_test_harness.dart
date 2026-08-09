import 'dart:math';

import 'package:authentication/authentication.dart';
import 'package:authentication/src/data/datasources/in_memory_auth_local_data_source.dart';
import 'package:authentication/src/data/datasources/mock_auth_remote_data_source.dart';
import 'package:authentication/src/data/repositories/mock_auth_repository_impl.dart';
import 'package:cart/cart.dart';
import 'package:cart/src/data/datasources/mock_cart_remote_data_source.dart';
import 'package:cart/src/data/repositories/mock_cart_repository_impl.dart';
import 'package:checkout/checkout.dart';
import 'package:checkout/src/data/datasources/mock_checkout_remote_data_source.dart';
import 'package:checkout/src/data/repositories/mock_checkout_repository_impl.dart';
import 'package:core/core.dart';
import 'package:orders/orders.dart';
import 'package:orders/src/data/datasources/mock_order_remote_data_source.dart';
import 'package:orders/src/data/repositories/mock_order_repository_impl.dart';
import 'package:products/products.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class CheckoutTestHarness {
  CheckoutTestHarness._({
    required this.controls,
    required this.store,
    required this.checkoutRepository,
    required this.orderRepository,
    required this.cartRepository,
    required this.authBloc,
    required this.placeOrder,
    required this.calculateShippingCost,
    required this.getSavedAddresses,
    required this.saveAddress,
    required this.getShippingMethods,
    required this.getCheckoutPaymentMethods,
    required this.getCartSummary,
  });

  final MockDeveloperControls controls;
  final MockSeedStore store;
  final CheckoutRepository checkoutRepository;
  final OrderRepository orderRepository;
  final CartRepository cartRepository;
  final AuthBloc authBloc;
  final PlaceOrder placeOrder;
  final CalculateShippingCost calculateShippingCost;
  final GetSavedAddresses getSavedAddresses;
  final SaveAddress saveAddress;
  final GetShippingMethods getShippingMethods;
  final GetCheckoutPaymentMethods getCheckoutPaymentMethods;
  final GetCartSummary getCartSummary;

  static Future<CheckoutTestHarness> create({bool loginDemoUser = true}) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final controls = MockDeveloperControls()..latencyDisabled = true;
    final store = MockSeedStore(controls: controls);
    const appConfig = AppConfig(
      environment: Environment.dev,
      dataSourceMode: DataSourceMode.mock,
      logLevel: LogLevel.debug,
      mockLatencyMin: Duration.zero,
      mockLatencyMax: Duration.zero,
      isDeveloperModeAvailable: true,
    );
    final simulator = MockNetworkSimulator(
      appConfig: appConfig,
      controls: controls,
      random: Random(0),
    );

    await getIt.reset();
    getIt.registerSingleton<AppConfig>(appConfig);
    getIt.registerSingleton<MockDeveloperControls>(controls);
    getIt.registerSingleton<MockSeedStore>(store);
    getIt.registerSingleton<MockNetworkSimulator>(simulator);
    configureProductsInjection();

    final cartRemote = MockCartRemoteDataSource(
      simulator: simulator,
      preferences: prefs,
      controls: controls,
      getProductDetail: getIt<GetProductDetail>(),
    );
    final cartRepository = MockCartRepositoryImpl(remote: cartRemote);

    final orderRemote = MockOrderRemoteDataSource(
      simulator: simulator,
      store: store,
      clock: () => DateTime.utc(2026, 8, 9, 12),
    );
    final orderRepository = MockOrderRepositoryImpl(remote: orderRemote);

    final checkoutRemote = MockCheckoutRemoteDataSource(
      simulator: simulator,
      preferences: prefs,
      controls: controls,
    );
    final checkoutRepository = MockCheckoutRepositoryImpl(
      remote: checkoutRemote,
    );

    final authRemote = MockAuthRemoteDataSource(
      simulator: simulator,
      store: store,
    );
    final authLocal = InMemoryAuthLocalDataSource();
    final authRepository = MockAuthRepositoryImpl(
      remote: authRemote,
      local: authLocal,
    );
    final authBloc = AuthBloc(
      restoreSession: RestoreSession(authRepository),
      loginUser: LoginUser(authRepository),
      registerUser: RegisterUser(authRepository),
      logoutUser: LogoutUser(authRepository),
      refreshSession: RefreshSession(authRepository),
    )..add(const AuthStarted());
    await authBloc.stream.firstWhere(
      (s) => s is AuthUnauthenticated || s is AuthAuthenticated,
    );

    if (loginDemoUser) {
      authBloc.add(
        const AuthLoginSubmitted(
          email: 'noah.patel02@example.com',
          password: 'Password123!',
        ),
      );
      await authBloc.stream.firstWhere((s) => s is AuthAuthenticated);
    }

    final getCartSummary = GetCartSummary(cartRepository);
    final clearCart = ClearCart(cartRepository);

    final placeOrder = PlaceOrder(
      getCartSummary: getCartSummary,
      clearCart: clearCart,
      orderRepository: orderRepository,
      checkoutRepository: checkoutRepository,
    );

    return CheckoutTestHarness._(
      controls: controls,
      store: store,
      checkoutRepository: checkoutRepository,
      orderRepository: orderRepository,
      cartRepository: cartRepository,
      authBloc: authBloc,
      placeOrder: placeOrder,
      calculateShippingCost: CalculateShippingCost(checkoutRepository),
      getSavedAddresses: GetSavedAddresses(checkoutRepository),
      saveAddress: SaveAddress(checkoutRepository),
      getShippingMethods: GetShippingMethods(checkoutRepository),
      getCheckoutPaymentMethods: GetCheckoutPaymentMethods(checkoutRepository),
      getCartSummary: getCartSummary,
    );
  }

  String get userId => (authBloc.state as AuthAuthenticated).session.user.id;

  CheckoutBloc createCheckoutBloc() {
    return CheckoutBloc(
      getSavedAddresses: getSavedAddresses,
      saveAddress: saveAddress,
      getShippingMethods: getShippingMethods,
      calculateShippingCost: calculateShippingCost,
      getCheckoutPaymentMethods: getCheckoutPaymentMethods,
      getCartSummary: getCartSummary,
      placeOrder: placeOrder,
      authBloc: authBloc,
    );
  }

  Future<void> seedCartLine() async {
    await cartRepository.addItem(
      ownerId: userId,
      productId: 'prod_001',
      variantId: 'prod_001_var_default',
      quantity: 1,
    );
  }

  Future<void> dispose() async {
    await authBloc.close();
    await getIt.reset();
  }
}
