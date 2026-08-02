import 'package:core/core.dart';
import 'package:equatable/equatable.dart';

import '../repositories/auth_repository.dart';

final class VerifyOtp extends UseCase<void, VerifyOtpParams> {
  const VerifyOtp(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<Failure, void>> call(VerifyOtpParams params) {
    return _repository.verifyOtp(
      email: params.email,
      code: params.code,
      purpose: params.purpose,
    );
  }
}

final class VerifyOtpParams extends Equatable {
  const VerifyOtpParams({
    required this.email,
    required this.code,
    required this.purpose,
  });

  final String email;
  final String code;
  final OtpPurpose purpose;

  @override
  List<Object?> get props => [email, code, purpose];
}
