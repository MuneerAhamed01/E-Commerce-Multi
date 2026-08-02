import 'dart:math';

import 'package:authentication/authentication.dart';
import 'package:authentication/src/data/datasources/in_memory_auth_local_data_source.dart';
import 'package:authentication/src/data/datasources/mock_auth_remote_data_source.dart';
import 'package:authentication/src/data/repositories/mock_auth_repository_impl.dart';
import 'package:cart/cart.dart';
import 'package:cart/src/data/datasources/mock_cart_remote_data_source.dart';
import 'package:cart/src/data/repositories/mock_cart_repository_impl.dart';
import 'package:core/core.dart';
import 'package:products/products.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class CartTestHarness {
  CartTestHarness._({
    required this.controls,
    required this.repository,
    required this.remote,
    required this.authBloc,
    required this.getCartSummary,
    required this.addToCart,
    required this.updateCartItemQuantity,
    required this.removeFromCart,
    required this.clearCart,
    required this.applyPromoCode,
    required this.removePromoCode,
  });

  final MockDeveloperControls controls;
  final CartRepository repository;
  final MockCartRemoteDataSource remote;
  final AuthBloc authBloc;
  final GetCartSummary getCartSummary;
  final AddToCart addToCart;
  final UpdateCartItemQuantity updateCartItemQuantity;
  final RemoveFromCart removeFromCart;
  final ClearCart clearCart;
  final ApplyPromoCode applyPromoCode;
  final RemovePromoCode removePromoCode;

  static Future<CartTestHarness> create() async {
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

    // Minimal products stack for GetProductDetail.
    await getIt.reset();
    getIt.registerSingleton<AppConfig>(appConfig);
    getIt.registerSingleton<MockDeveloperControls>(controls);
    getIt.registerSingleton<MockSeedStore>(store);
    getIt.registerSingleton<MockNetworkSimulator>(simulator);
    configureProductsInjection();

    final remote = MockCartRemoteDataSource(
      simulator: simulator,
      preferences: prefs,
      controls: controls,
      getProductDetail: getIt<GetProductDetail>(),
      clock: () => DateTime.utc(2026, 8, 2, 12),
    );
    final repository = MockCartRepositoryImpl(remote: remote);

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

    return CartTestHarness._(
      controls: controls,
      repository: repository,
      remote: remote,
      authBloc: authBloc,
      getCartSummary: GetCartSummary(
        repository,
        clock: () => DateTime.utc(2026, 8, 2, 12),
      ),
      addToCart: AddToCart(repository),
      updateCartItemQuantity: UpdateCartItemQuantity(repository),
      removeFromCart: RemoveFromCart(repository),
      clearCart: ClearCart(repository),
      applyPromoCode: ApplyPromoCode(repository),
      removePromoCode: RemovePromoCode(repository),
    );
  }

  CartBloc createBloc() {
    return CartBloc(
      getCartSummary: getCartSummary,
      addToCart: addToCart,
      updateCartItemQuantity: updateCartItemQuantity,
      removeFromCart: removeFromCart,
      clearCart: clearCart,
      applyPromoCode: applyPromoCode,
      removePromoCode: removePromoCode,
      cartRepository: repository,
      authBloc: authBloc,
      clock: () => DateTime.utc(2026, 8, 2, 12),
    );
  }

  Future<void> dispose() async {
    remote.dispose();
    await authBloc.close();
    await getIt.reset();
  }
}
