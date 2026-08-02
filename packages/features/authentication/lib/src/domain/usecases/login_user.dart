import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

final class LoginUser extends UseCase<AuthSession, LoginParams> {
  const LoginUser(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<Failure, AuthSession>> call(LoginParams params) {
    return _repository.login(
      email: params.email,
      password: params.password,
      requireAdmin: params.requireAdmin,
    );
  }
}

final class LoginParams extends Equatable {
  const LoginParams({
    required this.email,
    required this.password,
    this.requireAdmin = false,
  });

  final String email;
  final String password;

  /// When `true` (admin app login), customer accounts are rejected.
  final bool requireAdmin;

  @override
  List<Object?> get props => [email, password, requireAdmin];
}
