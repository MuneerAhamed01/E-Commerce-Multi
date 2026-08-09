import 'package:authentication/authentication.dart';
import 'package:core/core.dart';

import '../data/datasources/mock_order_remote_data_source.dart';
import '../data/datasources/order_remote_data_source.dart';
import '../data/repositories/mock_order_repository_impl.dart';
import '../domain/repositories/order_repository.dart';
import '../domain/usecases/cancel_order.dart';
import '../domain/usecases/create_order.dart';
import '../domain/usecases/get_order.dart';
import '../domain/usecases/get_order_tracking_events.dart';
import '../domain/usecases/get_orders.dart';
import '../domain/usecases/request_return.dart';
import '../presentation/bloc/order_detail_bloc.dart';
import '../presentation/bloc/order_list_bloc.dart';

/// Registers orders data/domain/presentation dependencies (Phase 15).
///
/// Call **after** [configureMockInjection] (and preferably after auth is
/// registered so [AuthBloc] exists for list/detail factories). Safe to call
/// once per process.
void configureOrdersInjection() {
  if (!getIt.isRegistered<MockNetworkSimulator>() ||
      !getIt.isRegistered<MockSeedStore>()) {
    throw StateError(
      'configureOrdersInjection() requires configureMockInjection() first.',
    );
  }

  if (!getIt.isRegistered<OrderRemoteDataSource>()) {
    getIt.registerLazySingleton<OrderRemoteDataSource>(
      () => MockOrderRemoteDataSource(
        simulator: getIt<MockNetworkSimulator>(),
        store: getIt<MockSeedStore>(),
      ),
    );
  }

  if (!getIt.isRegistered<OrderRepository>()) {
    getIt.registerLazySingleton<OrderRepository>(
      () => MockOrderRepositoryImpl(remote: getIt()),
    );
  }

  _registerFactory<CreateOrder>(() => CreateOrder(getIt()));
  _registerFactory<GetOrder>(() => GetOrder(getIt()));
  _registerFactory<GetOrders>(() => GetOrders(getIt()));
  _registerFactory<GetOrderTrackingEvents>(
    () => GetOrderTrackingEvents(getIt()),
  );
  _registerFactory<CancelOrder>(() => CancelOrder(getIt()));
  _registerFactory<RequestReturn>(() => RequestReturn(getIt()));

  _registerFactory<OrderListBloc>(
    () => OrderListBloc(getOrders: getIt(), authBloc: getIt()),
  );
  _registerFactory<OrderDetailBloc>(
    () => OrderDetailBloc(
      getOrder: getIt(),
      getTrackingEvents: getIt(),
      cancelOrder: getIt(),
      requestReturn: getIt(),
      authBloc: getIt(),
    ),
  );
}

void _registerFactory<T extends Object>(T Function() factory) {
  if (!getIt.isRegistered<T>()) {
    getIt.registerFactory<T>(factory);
  }
}
