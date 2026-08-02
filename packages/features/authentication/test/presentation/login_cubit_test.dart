import 'package:authentication/authentication.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/auth_test_harness.dart';

void main() {
  late AuthTestHarness harness;

  setUp(() {
    harness = AuthTestHarness.create();
  });

  blocTest<LoginCubit, LoginState>(
    'submit with empty fields emits validation errors',
    build: () => LoginCubit(authBloc: harness.createAuthBloc()),
    act: (cubit) => cubit.submit(),
    expect: () => [
      isA<LoginState>()
          .having((s) => s.emailError, 'emailError', isNotNull)
          .having((s) => s.passwordError, 'passwordError', isNotNull),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'valid credentials authenticate',
    build: () => harness.createAuthBloc(),
    act: (bloc) => bloc.add(
      const AuthLoginSubmitted(
        email: AuthDemoCredentials.customerEmail,
        password: AuthDemoCredentials.mockPassword,
      ),
    ),
    expect: () => [
      const AuthLoading(),
      isA<AuthAuthenticated>().having(
        (s) => s.session.user.email,
        'email',
        AuthDemoCredentials.customerEmail,
      ),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'invalid credentials show inline error (unauthenticated)',
    build: () => harness.createAuthBloc(),
    act: (bloc) => bloc.add(
      const AuthLoginSubmitted(
        email: AuthDemoCredentials.customerEmail,
        password: 'bad-password',
      ),
    ),
    expect: () => [
      const AuthLoading(),
      isA<AuthUnauthenticated>().having(
        (s) => s.errorMessage,
        'errorMessage',
        isNotNull,
      ),
    ],
  );
}
