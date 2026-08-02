import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/request_password_reset.dart';

enum ForgotPasswordStatus { idle, submitting, success, failure }

final class ForgotPasswordState extends Equatable {
  const ForgotPasswordState({
    this.email = '',
    this.emailError,
    this.status = ForgotPasswordStatus.idle,
    this.errorMessage,
  });

  final String email;
  final String? emailError;
  final ForgotPasswordStatus status;
  final String? errorMessage;

  ForgotPasswordState copyWith({
    String? email,
    String? emailError,
    ForgotPasswordStatus? status,
    String? errorMessage,
    bool clearEmailError = false,
    bool clearErrorMessage = false,
  }) {
    return ForgotPasswordState(
      email: email ?? this.email,
      emailError: clearEmailError ? null : (emailError ?? this.emailError),
      status: status ?? this.status,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [email, emailError, status, errorMessage];
}

final class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  ForgotPasswordCubit({required this.requestPasswordReset})
    : super(const ForgotPasswordState());

  final RequestPasswordReset requestPasswordReset;

  void emailChanged(String value) {
    emit(
      state.copyWith(
        email: value,
        clearEmailError: true,
        clearErrorMessage: true,
        status: ForgotPasswordStatus.idle,
      ),
    );
  }

  Future<void> submit() async {
    final emailError = Validators.email(state.email);
    if (emailError != null) {
      emit(state.copyWith(emailError: emailError));
      return;
    }
    emit(state.copyWith(status: ForgotPasswordStatus.submitting));
    final result = await requestPasswordReset(
      RequestPasswordResetParams(email: state.email.trim()),
    );
    result.fold(
      onFailure: (failure) {
        emit(
          state.copyWith(
            status: ForgotPasswordStatus.failure,
            errorMessage: failure.message ?? 'Unable to send reset code',
          ),
        );
      },
      onSuccess: (_) {
        emit(state.copyWith(status: ForgotPasswordStatus.success));
      },
    );
  }
}
