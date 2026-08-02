import 'package:core/core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/datasources/auth_local_data_source.dart';
import '../data/datasources/auth_remote_data_source.dart';
import '../data/datasources/mock_auth_remote_data_source.dart';
import '../data/repositories/mock_auth_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/usecases/get_current_user.dart';
import '../domain/usecases/get_onboarding_seen.dart';
import '../domain/usecases/login_user.dart';
import '../domain/usecases/logout_user.dart';
import '../domain/usecases/refresh_session.dart';
import '../domain/usecases/register_user.dart';
import '../domain/usecases/request_password_reset.dart';
import '../domain/usecases/reset_password.dart';
import '../domain/usecases/restore_session.dart';
import '../domain/usecases/set_onboarding_seen.dart';
import '../domain/usecases/verify_otp.dart';
import '../presentation/bloc/auth_bloc.dart';

/// Registers authentication data/domain/presentation dependencies.
///
/// Call **after** [configureMockInjection] so [MockNetworkSimulator] /
/// [MockSeedStore] exist. Safe to call once per process.
Future<void> configureAuthenticationInjection({
  SharedPreferences? preferences,
}) async {
  if (!getIt.isRegistered<MockNetworkSimulator>() ||
      !getIt.isRegistered<MockSeedStore>()) {
    throw StateError(
      'configureAuthenticationInjection() requires configureMockInjection() '
      'first.',
    );
  }

  if (!getIt.isRegistered<SharedPreferences>()) {
    final prefs = preferences ?? await SharedPreferences.getInstance();
    getIt.registerSingleton<SharedPreferences>(prefs);
  }

  if (!getIt.isRegistered<AuthLocalDataSource>()) {
    getIt.registerLazySingleton<AuthLocalDataSource>(
      () => SharedPreferencesAuthLocalDataSource(getIt<SharedPreferences>()),
    );
  }

  if (!getIt.isRegistered<AuthRemoteDataSource>()) {
    getIt.registerLazySingleton<AuthRemoteDataSource>(
      () => MockAuthRemoteDataSource(
        simulator: getIt<MockNetworkSimulator>(),
        store: getIt<MockSeedStore>(),
      ),
    );
  }

  if (!getIt.isRegistered<AuthRepository>()) {
    getIt.registerLazySingleton<AuthRepository>(
      () => MockAuthRepositoryImpl(
        remote: getIt<AuthRemoteDataSource>(),
        local: getIt<AuthLocalDataSource>(),
      ),
    );
  }

  _registerUseCase<LoginUser>(() => LoginUser(getIt()));
  _registerUseCase<RegisterUser>(() => RegisterUser(getIt()));
  _registerUseCase<LogoutUser>(() => LogoutUser(getIt()));
  _registerUseCase<RequestPasswordReset>(() => RequestPasswordReset(getIt()));
  _registerUseCase<VerifyOtp>(() => VerifyOtp(getIt()));
  _registerUseCase<ResetPassword>(() => ResetPassword(getIt()));
  _registerUseCase<GetCurrentUser>(() => GetCurrentUser(getIt()));
  _registerUseCase<RefreshSession>(() => RefreshSession(getIt()));
  _registerUseCase<RestoreSession>(() => RestoreSession(getIt()));
  _registerUseCase<GetOnboardingSeen>(() => GetOnboardingSeen(getIt()));
  _registerUseCase<SetOnboardingSeen>(() => SetOnboardingSeen(getIt()));

  if (!getIt.isRegistered<AuthBloc>()) {
    getIt.registerLazySingleton<AuthBloc>(
      () => AuthBloc(
        restoreSession: getIt<RestoreSession>(),
        loginUser: getIt<LoginUser>(),
        registerUser: getIt<RegisterUser>(),
        logoutUser: getIt<LogoutUser>(),
        refreshSession: getIt<RefreshSession>(),
      ),
    );
  }
}

void _registerUseCase<T extends Object>(T Function() factory) {
  if (!getIt.isRegistered<T>()) {
    getIt.registerFactory<T>(factory);
  }
}
