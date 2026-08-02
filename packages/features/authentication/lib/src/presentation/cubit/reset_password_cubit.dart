import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/reset_password.dart';

enum ResetPasswordStatus { idle, submitting, success, failure }

final class ResetPasswordState extends Equatable {
  const ResetPasswordState({
    this.password = '',
    this.confirmPassword = '',
    this.passwordError,
    this.confirmError,
    this.status = ResetPasswordStatus.idle,
    this.errorMessage,
  });

  final String password;
  final String confirmPassword;
  final String? passwordError;
  final String? confirmError;
  final ResetPasswordStatus status;
  final String? errorMessage;

  ResetPasswordState copyWith({
    String? password,
    String? confirmPassword,
    String? passwordError,
    String? confirmError,
    ResetPasswordStatus? status,
    String? errorMessage,
    bool clearPasswordError = false,
    bool clearConfirmError = false,
    bool clearErrorMessage = false,
  }) {
    return ResetPasswordState(
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      passwordError: clearPasswordError
          ? null
          : (passwordError ?? this.passwordError),
      confirmError: clearConfirmError
          ? null
          : (confirmError ?? this.confirmError),
      status: status ?? this.status,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    password,
    confirmPassword,
    passwordError,
    confirmError,
    status,
    errorMessage,
  ];
}

final class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  ResetPasswordCubit({required this.resetPassword, required this.email})
    : super(const ResetPasswordState());

  final ResetPassword resetPassword;
  final String email;

  void passwordChanged(String value) {
    emit(state.copyWith(password: value, clearPasswordError: true));
  }

  void confirmChanged(String value) {
    emit(state.copyWith(confirmPassword: value, clearConfirmError: true));
  }

  Future<void> submit() async {
    final passwordError = Validators.passwordStrength(state.password);
    final confirmError = state.confirmPassword != state.password
        ? 'Passwords do not match'
        : null;
    if (passwordError != null || confirmError != null) {
      emit(
        state.copyWith(
          passwordError: passwordError,
          confirmError: confirmError,
        ),
      );
      return;
    }
    emit(state.copyWith(status: ResetPasswordStatus.submitting));
    final result = await resetPassword(
      ResetPasswordParams(email: email, newPassword: state.password),
    );
    result.fold(
      onFailure: (failure) {
        emit(
          state.copyWith(
            status: ResetPasswordStatus.failure,
            errorMessage: failure.message ?? 'Unable to reset password',
          ),
        );
      },
      onSuccess: (_) {
        emit(state.copyWith(status: ResetPasswordStatus.success));
      },
    );
  }
}
