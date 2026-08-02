/// Mock call-type keys for auth endpoints (Developer Panel failure injection).
abstract final class AuthCallTypes {
  static const String login = 'auth.login';
  static const String register = 'auth.register';
  static const String logout = 'auth.logout';
  static const String requestPasswordReset = 'auth.requestPasswordReset';
  static const String verifyOtp = 'auth.verifyOtp';
  static const String resetPassword = 'auth.resetPassword';
  static const String refreshSession = 'auth.refreshSession';
  static const String getCurrentUser = 'auth.getCurrentUser';
}
