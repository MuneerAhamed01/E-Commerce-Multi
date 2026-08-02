import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

final class RegisterUser extends UseCase<AuthSession, RegisterParams> {
  const RegisterUser(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<Failure, AuthSession>> call(RegisterParams params) {
    return _repository.register(
      displayName: params.displayName,
      email: params.email,
      phone: params.phone,
      password: params.password,
    );
  }
}

final class RegisterParams extends Equatable {
  const RegisterParams({
    required this.displayName,
    required this.email,
    required this.phone,
    required this.password,
  });

  final String displayName;
  final String email;
  final String phone;
  final String password;

  @override
  List<Object?> get props => [displayName, email, phone, password];
}
