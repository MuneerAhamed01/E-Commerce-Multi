import 'package:authentication/authentication.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/auth_test_harness.dart';

void main() {
  late AuthTestHarness harness;

  setUp(() {
    harness = AuthTestHarness.create();
  });

  test('unauthenticated + onboarding not seen → onboarding', () async {
    final authBloc = harness.createAuthBloc();
    final done = authBloc.stream.firstWhere((s) => s is AuthUnauthenticated);
    authBloc.add(const AuthStarted());
    await done;

    final cubit = SplashCubit(
      authBloc: authBloc,
      getOnboardingSeen: harness.getOnboardingSeen,
      isAdminApp: false,
    );
    await cubit.resolve();
    expect(cubit.state.destination, SplashDestination.onboarding);
    await cubit.close();
    await authBloc.close();
  });

  test('unauthenticated + onboarding seen → login', () async {
    await harness.setOnboardingSeen(const SetOnboardingSeenParams(seen: true));
    final authBloc = harness.createAuthBloc();
    final done = authBloc.stream.firstWhere((s) => s is AuthUnauthenticated);
    authBloc.add(const AuthStarted());
    await done;

    final cubit = SplashCubit(
      authBloc: authBloc,
      getOnboardingSeen: harness.getOnboardingSeen,
      isAdminApp: false,
    );
    await cubit.resolve();
    expect(cubit.state.destination, SplashDestination.login);
    await cubit.close();
    await authBloc.close();
  });

  test('authenticated storefront → home', () async {
    final authBloc = harness.createAuthBloc();
    final done = authBloc.stream.firstWhere((s) => s is AuthAuthenticated);
    authBloc.add(
      const AuthLoginSubmitted(
        email: AuthDemoCredentials.customerEmail,
        password: AuthDemoCredentials.mockPassword,
      ),
    );
    await done;

    final cubit = SplashCubit(
      authBloc: authBloc,
      getOnboardingSeen: harness.getOnboardingSeen,
      isAdminApp: false,
    );
    await cubit.resolve();
    expect(cubit.state.destination, SplashDestination.home);
    await cubit.close();
    await authBloc.close();
  });

  test('authenticated admin → admin dashboard', () async {
    final authBloc = harness.createAuthBloc();
    final done = authBloc.stream.firstWhere((s) => s is AuthAuthenticated);
    authBloc.add(
      const AuthLoginSubmitted(
        email: AuthDemoCredentials.adminEmail,
        password: AuthDemoCredentials.mockPassword,
        requireAdmin: true,
      ),
    );
    await done;

    final cubit = SplashCubit(
      authBloc: authBloc,
      getOnboardingSeen: harness.getOnboardingSeen,
      isAdminApp: true,
    );
    await cubit.resolve();
    expect(cubit.state.destination, SplashDestination.adminDashboard);
    await cubit.close();
    await authBloc.close();
  });

  test('admin guest → admin login', () async {
    final authBloc = harness.createAuthBloc();
    final done = authBloc.stream.firstWhere((s) => s is AuthUnauthenticated);
    authBloc.add(const AuthStarted());
    await done;

    final cubit = SplashCubit(
      authBloc: authBloc,
      getOnboardingSeen: harness.getOnboardingSeen,
      isAdminApp: true,
    );
    await cubit.resolve();
    expect(cubit.state.destination, SplashDestination.adminLogin);
    await cubit.close();
    await authBloc.close();
  });
}
