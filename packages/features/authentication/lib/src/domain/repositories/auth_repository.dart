import 'package:core/core.dart';

import '../entities/auth_session.dart';
import '../entities/user.dart';

/// Auth persistence + identity contract (domain only).
abstract interface class AuthRepository {
  Future<Result<Failure, AuthSession>> login({
    required String email,
    required String password,
    bool requireAdmin = false,
  });

  Future<Result<Failure, AuthSession>> register({
    required String displayName,
    required String email,
    required String phone,
    required String password,
  });

  Future<Result<Failure, void>> logout();

  Future<Result<Failure, void>> requestPasswordReset({required String email});

  Future<Result<Failure, void>> verifyOtp({
    required String email,
    required String code,
    required OtpPurpose purpose,
  });

  Future<Result<Failure, void>> resetPassword({
    required String email,
    required String newPassword,
  });

  Future<Result<Failure, User?>> getCurrentUser();

  Future<Result<Failure, AuthSession?>> refreshSession();

  Future<Result<Failure, AuthSession?>> restoreSession();

  Future<Result<Failure, bool>> getOnboardingSeen();

  Future<Result<Failure, void>> setOnboardingSeen({required bool seen});
}

/// Why an OTP was issued (registration verification vs password recovery).
enum OtpPurpose { registration, passwordReset }
