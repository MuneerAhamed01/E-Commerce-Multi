import 'package:authentication/authentication.dart';
import 'package:authentication/src/data/mock/auth_call_types.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/auth_test_harness.dart';

void main() {
  late AuthTestHarness harness;

  setUp(() {
    harness = AuthTestHarness.create();
  });

  test('maps forced login failure to ServerFailure', () async {
    harness.controls.forceFailure(AuthCallTypes.login);

    final result = await harness.repository.login(
      email: AuthDemoCredentials.customerEmail,
      password: AuthDemoCredentials.mockPassword,
    );

    expect(result.isFailure, isTrue);
    expect(result.failureOrNull, isA<ServerFailure>());
  });

  test('duplicate register returns ValidationFailure', () async {
    final result = await harness.repository.register(
      displayName: 'Ava',
      email: AuthDemoCredentials.customerEmail,
      phone: '+15550101',
      password: AuthDemoCredentials.mockPassword,
    );

    expect(result.isFailure, isTrue);
    expect(result.failureOrNull, isA<ValidationFailure>());
  });
}
