/// Named path constants for auth screens (docs/09_ROUTING_PLAN.md §2 / §3).
abstract final class AuthRoutes {
  // Storefront
  static const String splashPath = '/splash';
  static const String splashName = 'SplashRoute';

  static const String onboardingPath = '/onboarding';
  static const String onboardingName = 'OnboardingRoute';

  static const String loginPath = '/login';
  static const String loginName = 'LoginRoute';

  static const String registerPath = '/register';
  static const String registerName = 'RegisterRoute';

  static const String forgotPasswordPath = '/forgot-password';
  static const String forgotPasswordName = 'ForgotPasswordRoute';

  static const String verifyOtpPath = '/verify-otp';
  static const String verifyOtpName = 'VerifyOtpRoute';

  static const String resetPasswordPath = '/reset-password';
  static const String resetPasswordName = 'ResetPasswordRoute';

  // Admin
  static const String adminSplashPath = '/admin/splash';
  static const String adminSplashName = 'AdminSplashRoute';

  static const String adminLoginPath = '/admin/login';
  static const String adminLoginName = 'AdminLoginRoute';

  static const String adminForgotPasswordPath = '/admin/forgot-password';
  static const String adminForgotPasswordName = 'AdminForgotPasswordRoute';

  static const String adminVerifyOtpPath = '/admin/verify-otp';
  static const String adminVerifyOtpName = 'AdminVerifyOtpRoute';

  static const String adminResetPasswordPath = '/admin/reset-password';
  static const String adminResetPasswordName = 'AdminResetPasswordRoute';

  static const String emailQueryKey = 'email';
  static const String purposeQueryKey = 'purpose';
}
