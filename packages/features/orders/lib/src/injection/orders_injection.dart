import 'package:core/core.dart';

import '../data/datasources/mock_order_remote_data_source.dart';
import '../data/datasources/order_remote_data_source.dart';
import '../data/repositories/mock_order_repository_impl.dart';
import '../domain/repositories/order_repository.dart';
import '../domain/usecases/create_order.dart';
import '../domain/usecases/get_order.dart';
import '../domain/usecases/get_orders.dart';

/// Registers orders data/domain dependencies (Phase 15.1).
///
/// Call **after** [configureMockInjection]. Safe to call once per process.
/// Presentation (history/detail UI) arrives in Phase 15.2+.
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
}

void _registerFactory<T extends Object>(T Function() factory) {
  if (!getIt.isRegistered<T>()) {
    getIt.registerFactory<T>(factory);
  }
}
