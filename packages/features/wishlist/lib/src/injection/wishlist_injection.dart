import 'package:authentication/authentication.dart';
import 'package:core/core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/datasources/mock_wishlist_remote_data_source.dart';
import '../data/datasources/wishlist_remote_data_source.dart';
import '../data/repositories/mock_wishlist_repository_impl.dart';
import '../domain/repositories/wishlist_repository.dart';
import '../domain/usecases/add_to_wishlist.dart';
import '../domain/usecases/get_wishlist.dart';
import '../domain/usecases/is_in_wishlist.dart';
import '../domain/usecases/remove_from_wishlist.dart';
import '../presentation/cubit/wishlist_cubit.dart';

/// Registers wishlist data/domain/presentation dependencies.
///
/// Call **after** [configureMockInjection] and
/// [configureAuthenticationInjection] so [MockNetworkSimulator] /
/// [SharedPreferences] / [AuthBloc] exist. Safe to call once per process.
void configureWishlistInjection() {
  if (!getIt.isRegistered<MockNetworkSimulator>() ||
      !getIt.isRegistered<MockSeedStore>() ||
      !getIt.isRegistered<MockDeveloperControls>()) {
    throw StateError(
      'configureWishlistInjection() requires configureMockInjection() first.',
    );
  }
  if (!getIt.isRegistered<SharedPreferences>()) {
    throw StateError(
      'configureWishlistInjection() requires SharedPreferences '
      '(configureAuthenticationInjection) first.',
    );
  }
  if (!getIt.isRegistered<AuthBloc>()) {
    throw StateError(
      'configureWishlistInjection() requires AuthBloc '
      '(configureAuthenticationInjection) first.',
    );
  }

  if (!getIt.isRegistered<WishlistRemoteDataSource>()) {
    getIt.registerLazySingleton<WishlistRemoteDataSource>(
      () => MockWishlistRemoteDataSource(
        simulator: getIt<MockNetworkSimulator>(),
        preferences: getIt<SharedPreferences>(),
        controls: getIt<MockDeveloperControls>(),
      ),
    );
  }

  if (!getIt.isRegistered<WishlistRepository>()) {
    getIt.registerLazySingleton<WishlistRepository>(
      () => MockWishlistRepositoryImpl(remote: getIt()),
    );
  }

  _registerFactory<GetWishlist>(() => GetWishlist(getIt()));
  _registerFactory<AddToWishlist>(() => AddToWishlist(getIt()));
  _registerFactory<RemoveFromWishlist>(() => RemoveFromWishlist(getIt()));
  _registerFactory<IsInWishlist>(() => IsInWishlist(getIt()));

  if (!getIt.isRegistered<WishlistCubit>()) {
    getIt.registerLazySingleton<WishlistCubit>(
      () => WishlistCubit(
        getWishlist: getIt(),
        addToWishlist: getIt(),
        removeFromWishlist: getIt(),
        authBloc: getIt(),
        seedStore: getIt(),
      ),
    );
  }
}

void _registerFactory<T extends Object>(T Function() factory) {
  if (!getIt.isRegistered<T>()) {
    getIt.registerFactory<T>(factory);
  }
}
