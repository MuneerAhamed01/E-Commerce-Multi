import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

import '../repositories/auth_repository.dart';

final class RequestPasswordReset
    extends UseCase<void, RequestPasswordResetParams> {
  const RequestPasswordReset(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<Failure, void>> call(RequestPasswordResetParams params) {
    return _repository.requestPasswordReset(email: params.email);
  }
}

final class RequestPasswordResetParams extends Equatable {
  const RequestPasswordResetParams({required this.email});

  final String email;

  @override
  List<Object?> get props => [email];
}
