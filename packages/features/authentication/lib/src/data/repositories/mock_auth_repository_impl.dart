import 'package:core/core.dart';

import '../../domain/entities/auth_session.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../datasources/mock_auth_remote_data_source.dart';
import '../models/auth_session_model.dart';

/// Maps data-layer exceptions → [Failure] (docs/10_DATA_FLOW.md §1).
final class MockAuthRepositoryImpl implements AuthRepository {
  MockAuthRepositoryImpl({required this.remote, required this.local});

  final AuthRemoteDataSource remote;
  final AuthLocalDataSource local;

  AuthSession? _memorySession;

  @override
  Future<Result<Failure, AuthSession>> login({
    required String email,
    required String password,
    bool requireAdmin = false,
  }) {
    return _guard(() async {
      final model = await remote.login(email: email, password: password);
      final session = model.toEntity();
      if (requireAdmin && !session.user.role.isAdminLike) {
        throw const UnauthorizedException(
          'This account does not have admin access',
        );
      }
      await _persist(model);
      return session;
    });
  }

  @override
  Future<Result<Failure, AuthSession>> register({
    required String displayName,
    required String email,
    required String phone,
    required String password,
  }) {
    return _guard(() async {
      final model = await remote.register(
        displayName: displayName,
        email: email,
        phone: phone,
        password: password,
      );
      await _persist(model);
      return model.toEntity();
    });
  }

  @override
  Future<Result<Failure, void>> logout() {
    return _guard(() async {
      final token = _memorySession?.accessToken;
      if (token != null) {
        await remote.logout(accessToken: token);
      }
      _memorySession = null;
      await local.clearSession();
    });
  }

  @override
  Future<Result<Failure, void>> requestPasswordReset({required String email}) {
    return _guard(() => remote.requestPasswordReset(email: email));
  }

  @override
  Future<Result<Failure, void>> verifyOtp({
    required String email,
    required String code,
    required OtpPurpose purpose,
  }) {
    return _guard(
      () => remote.verifyOtp(email: email, code: code, purpose: purpose),
    );
  }

  @override
  Future<Result<Failure, void>> resetPassword({
    required String email,
    required String newPassword,
  }) {
    return _guard(
      () => remote.resetPassword(email: email, newPassword: newPassword),
    );
  }

  @override
  Future<Result<Failure, User?>> getCurrentUser() {
    return _guard(() async {
      final session = _memorySession;
      if (session == null) {
        return null;
      }
      final user = await remote.fetchCurrentUser(
        accessToken: session.accessToken,
      );
      return user?.toEntity() ?? session.user;
    });
  }

  @override
  Future<Result<Failure, AuthSession?>> refreshSession() {
    return _guard(() async {
      final current = _memorySession;
      if (current == null) {
        return null;
      }
      if (!current.isExpired) {
        return current;
      }
      final model = await remote.refreshSession(
        refreshToken: current.refreshToken,
      );
      await _persist(model);
      return model.toEntity();
    });
  }

  @override
  Future<Result<Failure, AuthSession?>> restoreSession() {
    return _guard(() async {
      final stored = await local.readSession();
      if (stored == null) {
        _memorySession = null;
        return null;
      }
      final session = stored.toEntity();
      if (session.isExpired) {
        try {
          final refreshed = await remote.refreshSession(
            refreshToken: session.refreshToken,
          );
          await _persist(refreshed);
          return refreshed.toEntity();
        } on UnauthorizedException {
          await local.clearSession();
          _memorySession = null;
          return null;
        }
      }
      final activeRemote = remote;
      if (activeRemote is MockAuthRemoteDataSource) {
        activeRemote.adoptSession(stored);
      }
      _memorySession = session;
      return session;
    });
  }

  @override
  Future<Result<Failure, bool>> getOnboardingSeen() {
    return _guard(local.readOnboardingSeen);
  }

  @override
  Future<Result<Failure, void>> setOnboardingSeen({required bool seen}) {
    return _guard(() => local.writeOnboardingSeen(seen));
  }

  Future<void> _persist(AuthSessionModel model) async {
    _memorySession = model.toEntity();
    await local.writeSession(model);
  }

  Future<Result<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Result.success(await action());
    } on ServerException catch (e) {
      return Result.failure(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    } on CacheException catch (e) {
      return Result.failure(CacheFailure(message: e.message));
    } on NetworkException catch (e) {
      return Result.failure(NetworkFailure(message: e.message));
    } on NotFoundException catch (e) {
      return Result.failure(NotFoundFailure(message: e.message));
    } on UnauthorizedException catch (e) {
      return Result.failure(UnauthorizedFailure(message: e.message));
    } on ValidationException catch (e) {
      return Result.failure(
        ValidationFailure(e.fieldErrors, message: e.message),
      );
    } on AppException catch (e) {
      return Result.failure(UnknownFailure(message: e.message));
    } on Object catch (e) {
      return Result.failure(UnknownFailure(message: e.toString()));
    }
  }
}
