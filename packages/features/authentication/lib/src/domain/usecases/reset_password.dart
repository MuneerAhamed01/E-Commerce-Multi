import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

import '../repositories/auth_repository.dart';

final class ResetPassword extends UseCase<void, ResetPasswordParams> {
  const ResetPassword(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<Failure, void>> call(ResetPasswordParams params) {
    return _repository.resetPassword(
      email: params.email,
      newPassword: params.newPassword,
    );
  }
}

final class ResetPasswordParams extends Equatable {
  const ResetPasswordParams({required this.email, required this.newPassword});

  final String email;
  final String newPassword;

  @override
  List<Object?> get props => [email, newPassword];
}
