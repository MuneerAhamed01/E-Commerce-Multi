import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/verify_otp.dart';

enum OtpStatus { idle, submitting, success, failure }

final class OtpState extends Equatable {
  const OtpState({
    this.status = OtpStatus.idle,
    this.hasError = false,
    this.errorMessage,
  });

  final OtpStatus status;
  final bool hasError;
  final String? errorMessage;

  OtpState copyWith({
    OtpStatus? status,
    bool? hasError,
    String? errorMessage,
    bool clearError = false,
  }) {
    return OtpState(
      status: status ?? this.status,
      hasError: hasError ?? this.hasError,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, hasError, errorMessage];
}

final class OtpCubit extends Cubit<OtpState> {
  OtpCubit({
    required this.verifyOtp,
    required this.email,
    required this.purpose,
  }) : super(const OtpState());

  final VerifyOtp verifyOtp;
  final String email;
  final OtpPurpose purpose;

  Future<void> submit(String code) async {
    emit(
      state.copyWith(
        status: OtpStatus.submitting,
        hasError: false,
        clearError: true,
      ),
    );
    final result = await verifyOtp(
      VerifyOtpParams(email: email, code: code, purpose: purpose),
    );
    result.fold(
      onFailure: (failure) {
        final message = switch (failure) {
          ValidationFailure(:final fieldErrors) =>
            fieldErrors['otp'] ?? 'Invalid verification code',
          _ => failure.message ?? 'Invalid verification code',
        };
        emit(
          state.copyWith(
            status: OtpStatus.failure,
            hasError: true,
            errorMessage: message,
          ),
        );
      },
      onSuccess: (_) {
        emit(state.copyWith(status: OtpStatus.success, hasError: false));
      },
    );
  }
}
