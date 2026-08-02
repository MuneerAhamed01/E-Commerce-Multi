import 'dart:math';

import 'package:authentication/authentication.dart';
import 'package:authentication/src/data/datasources/in_memory_auth_local_data_source.dart';
import 'package:authentication/src/data/datasources/mock_auth_remote_data_source.dart';
import 'package:authentication/src/data/repositories/mock_auth_repository_impl.dart';
import 'package:core/core.dart';
import 'package:wishlist/src/data/datasources/in_memory_wishlist_remote_data_source.dart';
import 'package:wishlist/src/data/datasources/wishlist_remote_data_source.dart';
import 'package:wishlist/src/data/repositories/mock_wishlist_repository_impl.dart';
import 'package:wishlist/wishlist.dart';

final class WishlistTestHarness {
  WishlistTestHarness._({
    required this.controls,
    required this.store,
    required this.repository,
    required this.remote,
    required this.getWishlist,
    required this.addToWishlist,
    required this.removeFromWishlist,
    required this.isInWishlist,
    required this.authBloc,
  });

  final MockDeveloperControls controls;
  final MockSeedStore store;
  final WishlistRepository repository;
  final WishlistRemoteDataSource remote;
  final GetWishlist getWishlist;
  final AddToWishlist addToWishlist;
  final RemoveFromWishlist removeFromWishlist;
  final IsInWishlist isInWishlist;
  final AuthBloc authBloc;

  static Future<WishlistTestHarness> create() async {
    final controls = MockDeveloperControls()..latencyDisabled = true;
    final store = MockSeedStore(controls: controls);
    final simulator = MockNetworkSimulator(
      appConfig: const AppConfig(
        environment: Environment.dev,
        dataSourceMode: DataSourceMode.mock,
        logLevel: LogLevel.debug,
        mockLatencyMin: Duration.zero,
        mockLatencyMax: Duration.zero,
        isDeveloperModeAvailable: true,
      ),
      controls: controls,
      random: Random(0),
    );
    final remote = InMemoryWishlistRemoteDataSource(
      simulator: simulator,
      controls: controls,
      clock: () => DateTime.utc(2026, 8, 2, 12),
    );
    final repository = MockWishlistRepositoryImpl(remote: remote);

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

    return WishlistTestHarness._(
      controls: controls,
      store: store,
      repository: repository,
      remote: remote,
      getWishlist: GetWishlist(repository),
      addToWishlist: AddToWishlist(repository),
      removeFromWishlist: RemoveFromWishlist(repository),
      isInWishlist: IsInWishlist(repository),
      authBloc: authBloc,
    );
  }

  WishlistCubit createCubit() {
    return WishlistCubit(
      getWishlist: getWishlist,
      addToWishlist: addToWishlist,
      removeFromWishlist: removeFromWishlist,
      authBloc: authBloc,
      seedStore: store,
    );
  }

  Future<void> loginAsDemoCustomer() async {
    authBloc.add(
      const AuthLoginSubmitted(
        email: AuthDemoCredentials.customerEmail,
        password: AuthDemoCredentials.mockPassword,
      ),
    );
    await authBloc.stream.firstWhere((s) => s is AuthAuthenticated);
  }

  Future<void> loginAs({
    required String email,
    required String password,
  }) async {
    authBloc.add(AuthLoginSubmitted(email: email, password: password));
    await authBloc.stream.firstWhere((s) => s is AuthAuthenticated);
  }

  Future<void> dispose() async {
    final current = remote;
    if (current is InMemoryWishlistRemoteDataSource) {
      current.dispose();
    }
    await authBloc.close();
  }
}
