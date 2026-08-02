import 'package:authentication/authentication.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/auth_test_harness.dart';

void main() {
  late AuthTestHarness harness;

  setUp(() {
    harness = AuthTestHarness.create();
  });

  test('register creates session and persists across restore', () async {
    final registered = await harness.registerUser(
      const RegisterParams(
        displayName: 'New Shopper',
        email: 'new.shopper@example.com',
        phone: '+15550199',
        password: AuthDemoCredentials.mockPassword,
      ),
    );

    expect(registered.isSuccess, isTrue);

    final restored = await harness.restoreSession(const NoParams());
    expect(restored.isSuccess, isTrue);
    expect(restored.valueOrNull?.user.email, 'new.shopper@example.com');
  });

  test('logout clears persisted session', () async {
    await harness.loginUser(
      const LoginParams(
        email: AuthDemoCredentials.customerEmail,
        password: AuthDemoCredentials.mockPassword,
      ),
    );

    final logout = await harness.logoutUser(const NoParams());
    expect(logout.isSuccess, isTrue);

    final restored = await harness.restoreSession(const NoParams());
    expect(restored.valueOrNull, isNull);
  });

  test('password reset flow with mock OTP', () async {
    final request = await harness.requestPasswordReset(
      const RequestPasswordResetParams(
        email: AuthDemoCredentials.customerEmail,
      ),
    );
    expect(request.isSuccess, isTrue);

    final badOtp = await harness.verifyOtp(
      const VerifyOtpParams(
        email: AuthDemoCredentials.customerEmail,
        code: '000000',
        purpose: OtpPurpose.passwordReset,
      ),
    );
    expect(badOtp.isFailure, isTrue);

    final goodOtp = await harness.verifyOtp(
      const VerifyOtpParams(
        email: AuthDemoCredentials.customerEmail,
        code: AuthDemoCredentials.mockOtp,
        purpose: OtpPurpose.passwordReset,
      ),
    );
    expect(goodOtp.isSuccess, isTrue);

    const newPassword = 'NewPass123!';
    final reset = await harness.resetPassword(
      const ResetPasswordParams(
        email: AuthDemoCredentials.customerEmail,
        newPassword: newPassword,
      ),
    );
    expect(reset.isSuccess, isTrue);

    final oldLogin = await harness.loginUser(
      const LoginParams(
        email: AuthDemoCredentials.customerEmail,
        password: AuthDemoCredentials.mockPassword,
      ),
    );
    expect(oldLogin.isFailure, isTrue);

    final newLogin = await harness.loginUser(
      const LoginParams(
        email: AuthDemoCredentials.customerEmail,
        password: newPassword,
      ),
    );
    expect(newLogin.isSuccess, isTrue);
  });

  test('onboarding seen flag persists', () async {
    final before = await harness.getOnboardingSeen(const NoParams());
    expect(before.valueOrNull, isFalse);

    await harness.setOnboardingSeen(const SetOnboardingSeenParams(seen: true));
    final after = await harness.getOnboardingSeen(const NoParams());
    expect(after.valueOrNull, isTrue);
  });
}
