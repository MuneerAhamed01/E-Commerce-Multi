import 'package:authentication/authentication.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/auth_test_harness.dart';

void main() {
  late AuthTestHarness harness;

  setUp(() {
    harness = AuthTestHarness.create();
  });

  test('login succeeds for seeded customer', () async {
    final result = await harness.loginUser(
      const LoginParams(
        email: AuthDemoCredentials.customerEmail,
        password: AuthDemoCredentials.mockPassword,
      ),
    );

    expect(
      result.isSuccess,
      isTrue,
      reason: result.failureOrNull?.message ?? 'login failed',
    );
    expect(result.valueOrNull!.user.email, AuthDemoCredentials.customerEmail);
    expect(result.valueOrNull!.user.role, UserRole.customer);
  });

  test('login fails for wrong password', () async {
    final result = await harness.loginUser(
      const LoginParams(
        email: AuthDemoCredentials.customerEmail,
        password: 'wrong-password',
      ),
    );

    expect(result.isFailure, isTrue);
    expect(result.failureOrNull, isA<UnauthorizedFailure>());
  });

  test('requireAdmin rejects customer accounts', () async {
    final result = await harness.loginUser(
      const LoginParams(
        email: AuthDemoCredentials.customerEmail,
        password: AuthDemoCredentials.mockPassword,
        requireAdmin: true,
      ),
    );

    expect(result.isFailure, isTrue);
    expect(result.failureOrNull, isA<UnauthorizedFailure>());
  });

  test('requireAdmin accepts admin accounts', () async {
    final result = await harness.loginUser(
      const LoginParams(
        email: AuthDemoCredentials.adminEmail,
        password: AuthDemoCredentials.mockPassword,
        requireAdmin: true,
      ),
    );

    expect(result.isSuccess, isTrue);
    expect(result.valueOrNull!.user.role, UserRole.admin);
  });
}
