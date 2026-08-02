import 'dart:math';

import 'package:authentication/src/data/datasources/in_memory_auth_local_data_source.dart';
import 'package:authentication/src/data/datasources/mock_auth_remote_data_source.dart';
import 'package:authentication/src/data/repositories/mock_auth_repository_impl.dart';
import 'package:authentication/src/domain/repositories/auth_repository.dart';
import 'package:authentication/src/domain/usecases/get_onboarding_seen.dart';
import 'package:authentication/src/domain/usecases/login_user.dart';
import 'package:authentication/src/domain/usecases/logout_user.dart';
import 'package:authentication/src/domain/usecases/refresh_session.dart';
import 'package:authentication/src/domain/usecases/register_user.dart';
import 'package:authentication/src/domain/usecases/request_password_reset.dart';
import 'package:authentication/src/domain/usecases/reset_password.dart';
import 'package:authentication/src/domain/usecases/restore_session.dart';
import 'package:authentication/src/domain/usecases/set_onboarding_seen.dart';
import 'package:authentication/src/domain/usecases/verify_otp.dart';
import 'package:authentication/src/presentation/bloc/auth_bloc.dart';
import 'package:core/core.dart';

final class AuthTestHarness {
  AuthTestHarness._({
    required this.controls,
    required this.store,
    required this.repository,
    required this.loginUser,
    required this.registerUser,
    required this.logoutUser,
    required this.requestPasswordReset,
    required this.verifyOtp,
    required this.resetPassword,
    required this.restoreSession,
    required this.refreshSession,
    required this.getOnboardingSeen,
    required this.setOnboardingSeen,
  });

  final MockDeveloperControls controls;
  final MockSeedStore store;
  final AuthRepository repository;
  final LoginUser loginUser;
  final RegisterUser registerUser;
  final LogoutUser logoutUser;
  final RequestPasswordReset requestPasswordReset;
  final VerifyOtp verifyOtp;
  final ResetPassword resetPassword;
  final RestoreSession restoreSession;
  final RefreshSession refreshSession;
  final GetOnboardingSeen getOnboardingSeen;
  final SetOnboardingSeen setOnboardingSeen;

  static AuthTestHarness create() {
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
    final remote = MockAuthRemoteDataSource(simulator: simulator, store: store);
    final local = InMemoryAuthLocalDataSource();
    final repository = MockAuthRepositoryImpl(remote: remote, local: local);

    return AuthTestHarness._(
      controls: controls,
      store: store,
      repository: repository,
      loginUser: LoginUser(repository),
      registerUser: RegisterUser(repository),
      logoutUser: LogoutUser(repository),
      requestPasswordReset: RequestPasswordReset(repository),
      verifyOtp: VerifyOtp(repository),
      resetPassword: ResetPassword(repository),
      restoreSession: RestoreSession(repository),
      refreshSession: RefreshSession(repository),
      getOnboardingSeen: GetOnboardingSeen(repository),
      setOnboardingSeen: SetOnboardingSeen(repository),
    );
  }

  AuthBloc createAuthBloc() {
    return AuthBloc(
      restoreSession: restoreSession,
      loginUser: loginUser,
      registerUser: registerUser,
      logoutUser: logoutUser,
      refreshSession: refreshSession,
    );
  }
}
