import 'dart:math';

import 'package:authentication/authentication.dart';
import 'package:authentication/src/data/datasources/in_memory_auth_local_data_source.dart';
import 'package:authentication/src/data/datasources/mock_auth_remote_data_source.dart';
import 'package:authentication/src/data/repositories/mock_auth_repository_impl.dart';
import 'package:core/core.dart';
import 'package:orders/orders.dart';
import 'package:orders/src/data/datasources/mock_order_remote_data_source.dart';
import 'package:orders/src/data/repositories/mock_order_repository_impl.dart';

final class OrdersTestHarness {
  OrdersTestHarness._({
    required this.controls,
    required this.store,
    required this.repository,
    required this.authBloc,
    required this.getOrders,
    required this.getOrder,
    required this.getTrackingEvents,
    required this.cancelOrder,
    required this.requestReturn,
  });

  final MockDeveloperControls controls;
  final MockSeedStore store;
  final OrderRepository repository;
  final AuthBloc authBloc;
  final GetOrders getOrders;
  final GetOrder getOrder;
  final GetOrderTrackingEvents getTrackingEvents;
  final CancelOrder cancelOrder;
  final RequestReturn requestReturn;

  String get userId => 'user_cust_02';

  /// Mutates the first owned seed order to [status] (for policy UI tests).
  String setOwnedOrderStatus(OrderStatus status) {
    final index = store.orders.indexWhere((o) => o.customerId == userId);
    if (index < 0) {
      throw StateError('No seeded orders for $userId');
    }
    final seed = store.orders[index];
    store.orders[index] = SeedOrder(
      id: seed.id,
      orderNumber: seed.orderNumber,
      customerId: seed.customerId,
      status: status.toSeed(),
      createdAtIso: seed.createdAtIso,
      items: seed.items,
      shippingAddress: seed.shippingAddress,
      subtotal: seed.subtotal,
      shipping: seed.shipping,
      tax: seed.tax,
      total: seed.total,
    );
    return seed.id;
  }

  static Future<OrdersTestHarness> create({bool loginDemoUser = true}) async {
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

    final repository = MockOrderRepositoryImpl(
      remote: MockOrderRemoteDataSource(
        simulator: simulator,
        store: store,
        clock: () => DateTime.utc(2026, 8, 9, 12),
      ),
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
          email: AuthDemoCredentials.customerEmail,
          password: AuthDemoCredentials.mockPassword,
        ),
      );
      await authBloc.stream.firstWhere((s) => s is AuthAuthenticated);
    }

    return OrdersTestHarness._(
      controls: controls,
      store: store,
      repository: repository,
      authBloc: authBloc,
      getOrders: GetOrders(repository),
      getOrder: GetOrder(repository),
      getTrackingEvents: GetOrderTrackingEvents(repository),
      cancelOrder: CancelOrder(repository),
      requestReturn: RequestReturn(repository),
    );
  }

  OrderListBloc createListBloc() {
    return OrderListBloc(getOrders: getOrders, authBloc: authBloc);
  }

  OrderDetailBloc createDetailBloc() {
    return OrderDetailBloc(
      getOrder: getOrder,
      getTrackingEvents: getTrackingEvents,
      cancelOrder: cancelOrder,
      requestReturn: requestReturn,
      authBloc: authBloc,
    );
  }

  Future<void> dispose() async {
    await authBloc.close();
  }
}
