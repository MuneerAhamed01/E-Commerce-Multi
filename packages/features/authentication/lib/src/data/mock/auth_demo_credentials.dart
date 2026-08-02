/// Documented QA credentials for the mock auth layer (Phase 7).
///
/// All [SeedData.users] share [mockPassword]. OTP verification always
/// accepts [mockOtp] in non-prod mock mode.
abstract final class AuthDemoCredentials {
  /// Shared password for every seeded mock user.
  static const String mockPassword = 'Password123!';

  /// Fixed mock OTP accepted by [MockAuthRemoteDataSource] (non-prod).
  static const String mockOtp = '123456';

  /// Seeded platform admin (`role: admin`).
  static const String adminEmail = 'admin@example.com';

  /// Seeded support agent (`role: support`).
  static const String supportEmail = 'support@example.com';

  /// Seeded active customer (`user_cust_02` — Noah Patel).
  ///
  /// Note: `user_cust_01` is intentionally inactive in [SeedData]
  /// (`isActive: i % 11 != 0`), so demos use the second customer.
  static const String customerEmail = 'noah.patel02@example.com';
}
