import 'package:core/core.dart';

import '../../domain/repositories/auth_repository.dart';
import '../mock/auth_call_types.dart';
import '../mock/auth_demo_credentials.dart';
import '../models/auth_session_model.dart';
import '../models/user_model.dart';
import 'auth_remote_data_source.dart';

/// In-memory mock auth remote (docs/10_DATA_FLOW.md §2).
///
/// Demo credentials: see [AuthDemoCredentials].
final class MockAuthRemoteDataSource
    with MockDataSourceMixin
    implements AuthRemoteDataSource {
  MockAuthRemoteDataSource({required this.simulator, required this.store}) {
    _seedPasswords();
  }

  @override
  final MockNetworkSimulator simulator;

  final MockSeedStore store;

  /// email (lowercased) → password
  final Map<String, String> _passwords = {};

  /// email → pending OTP purpose after request/register.
  final Map<String, OtpPurpose> _pendingOtps = {};

  /// email → verified OTP purpose (gate for password reset).
  final Map<String, OtpPurpose> _verifiedOtps = {};

  AuthSessionModel? _activeSession;

  void _seedPasswords() {
    for (final user in store.users) {
      _passwords[user.email.toLowerCase()] = AuthDemoCredentials.mockPassword;
    }
  }

  @override
  Future<AuthSessionModel> login({
    required String email,
    required String password,
  }) {
    return guarded(AuthCallTypes.login, () async {
      final normalized = email.trim().toLowerCase();
      final seed = _findUser(normalized);
      if (seed == null || _passwords[normalized] != password) {
        throw const UnauthorizedException('Invalid email or password');
      }
      if (!seed.isActive) {
        throw const UnauthorizedException('Account is suspended');
      }
      final session = _issueSession(UserModel.fromSeed(seed));
      _activeSession = session;
      return session;
    });
  }

  @override
  Future<AuthSessionModel> register({
    required String displayName,
    required String email,
    required String phone,
    required String password,
  }) {
    return guarded(AuthCallTypes.register, () async {
      final normalized = email.trim().toLowerCase();
      if (_findUser(normalized) != null) {
        throw const ValidationException({
          'email': 'An account with this email already exists',
        }, 'Duplicate email');
      }
      final id = 'user_cust_${DateTime.now().toUtc().millisecondsSinceEpoch}';
      final seed = SeedUser(
        id: id,
        email: normalized,
        displayName: displayName.trim(),
        role: 'customer',
        phone: phone.trim(),
      );
      store.users.add(seed);
      _passwords[normalized] = password;
      final session = _issueSession(UserModel.fromSeed(seed));
      _activeSession = session;
      return session;
    });
  }

  @override
  Future<void> logout({required String accessToken}) {
    return guarded(AuthCallTypes.logout, () async {
      if (_activeSession?.accessToken == accessToken) {
        _activeSession = null;
      }
    });
  }

  @override
  Future<void> requestPasswordReset({required String email}) {
    return guarded(AuthCallTypes.requestPasswordReset, () async {
      final normalized = email.trim().toLowerCase();
      // Neutral success even for unknown emails (no enumeration).
      if (_findUser(normalized) != null) {
        _pendingOtps[normalized] = OtpPurpose.passwordReset;
      }
    });
  }

  @override
  Future<void> verifyOtp({
    required String email,
    required String code,
    required OtpPurpose purpose,
  }) {
    return guarded(AuthCallTypes.verifyOtp, () async {
      final normalized = email.trim().toLowerCase();
      if (code != AuthDemoCredentials.mockOtp) {
        throw const ValidationException({
          'otp': 'Invalid verification code',
        }, 'Invalid OTP');
      }
      final pending = _pendingOtps[normalized];
      if (pending != purpose && purpose == OtpPurpose.passwordReset) {
        // Allow verify when request was recorded, or when user exists
        // (QA convenience if request was skipped in tests).
        if (_findUser(normalized) == null) {
          throw const ValidationException({
            'otp': 'No verification pending for this email',
          }, 'OTP not requested');
        }
      }
      _pendingOtps.remove(normalized);
      _verifiedOtps[normalized] = purpose;
    });
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String newPassword,
  }) {
    return guarded(AuthCallTypes.resetPassword, () async {
      final normalized = email.trim().toLowerCase();
      if (_verifiedOtps[normalized] != OtpPurpose.passwordReset) {
        throw const UnauthorizedException('OTP verification required');
      }
      if (_findUser(normalized) == null) {
        throw const NotFoundException('User not found');
      }
      _passwords[normalized] = newPassword;
      _verifiedOtps.remove(normalized);
    });
  }

  @override
  Future<UserModel?> fetchCurrentUser({required String accessToken}) {
    return guarded(AuthCallTypes.getCurrentUser, () async {
      final session = _activeSession;
      if (session == null || session.accessToken != accessToken) {
        return null;
      }
      return session.user;
    });
  }

  @override
  Future<AuthSessionModel> refreshSession({required String refreshToken}) {
    return guarded(AuthCallTypes.refreshSession, () async {
      final current = _activeSession;
      if (current == null || current.refreshToken != refreshToken) {
        throw const UnauthorizedException('Invalid refresh token');
      }
      final refreshed = _issueSession(current.user);
      _activeSession = refreshed;
      return refreshed;
    });
  }

  /// Restores the in-memory active session pointer after a cold start
  /// (local persistence already validated the tokens).
  void adoptSession(AuthSessionModel session) {
    _activeSession = session;
    final email = session.user.email.toLowerCase();
    _passwords.putIfAbsent(email, () => AuthDemoCredentials.mockPassword);
  }

  SeedUser? _findUser(String normalizedEmail) {
    for (final user in store.users) {
      if (user.email.toLowerCase() == normalizedEmail) {
        return user;
      }
    }
    return null;
  }

  AuthSessionModel _issueSession(UserModel user) {
    final now = DateTime.now().toUtc();
    final tokenSuffix = now.microsecondsSinceEpoch.toString();
    return AuthSessionModel(
      user: user,
      accessToken: 'mock_access_${user.id}_$tokenSuffix',
      refreshToken: 'mock_refresh_${user.id}_$tokenSuffix',
      expiresAtIso: now.add(const Duration(days: 7)).toIso8601String(),
    );
  }
}
