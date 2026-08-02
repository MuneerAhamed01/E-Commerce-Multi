import '../../domain/repositories/auth_repository.dart';
import '../models/auth_session_model.dart';
import '../models/user_model.dart';

/// Remote auth contract — mock today, Firebase Auth later.
abstract interface class AuthRemoteDataSource {
  Future<AuthSessionModel> login({
    required String email,
    required String password,
  });

  Future<AuthSessionModel> register({
    required String displayName,
    required String email,
    required String phone,
    required String password,
  });

  Future<void> logout({required String accessToken});

  Future<void> requestPasswordReset({required String email});

  Future<void> verifyOtp({
    required String email,
    required String code,
    required OtpPurpose purpose,
  });

  Future<void> resetPassword({
    required String email,
    required String newPassword,
  });

  Future<UserModel?> fetchCurrentUser({required String accessToken});

  Future<AuthSessionModel> refreshSession({required String refreshToken});
}
