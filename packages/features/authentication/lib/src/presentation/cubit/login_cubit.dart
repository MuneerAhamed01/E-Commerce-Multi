import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';

final class LoginState extends Equatable {
  const LoginState({
    this.email = '',
    this.password = '',
    this.emailError,
    this.passwordError,
  });

  final String email;
  final String password;
  final String? emailError;
  final String? passwordError;

  bool get isValid =>
      emailError == null &&
      passwordError == null &&
      email.trim().isNotEmpty &&
      password.isNotEmpty;

  LoginState copyWith({
    String? email,
    String? password,
    String? emailError,
    String? passwordError,
    bool clearEmailError = false,
    bool clearPasswordError = false,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      emailError: clearEmailError ? null : (emailError ?? this.emailError),
      passwordError: clearPasswordError
          ? null
          : (passwordError ?? this.passwordError),
    );
  }

  @override
  List<Object?> get props => [email, password, emailError, passwordError];
}

/// Form-local state for Login; session mutations go through [AuthBloc].
final class LoginCubit extends Cubit<LoginState> {
  LoginCubit({required this.authBloc, this.requireAdmin = false})
    : super(const LoginState());

  final AuthBloc authBloc;
  final bool requireAdmin;

  void emailChanged(String value) {
    emit(state.copyWith(email: value, clearEmailError: true));
  }

  void passwordChanged(String value) {
    emit(state.copyWith(password: value, clearPasswordError: true));
  }

  void submit() {
    final emailError = _validateEmail(state.email);
    final passwordError = state.password.isEmpty
        ? 'Password is required'
        : null;
    if (emailError != null || passwordError != null) {
      emit(
        state.copyWith(emailError: emailError, passwordError: passwordError),
      );
      return;
    }
    authBloc.add(
      AuthLoginSubmitted(
        email: state.email.trim(),
        password: state.password,
        requireAdmin: requireAdmin,
      ),
    );
  }

  String? _validateEmail(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$').hasMatch(trimmed)) {
      return 'Enter a valid email address';
    }
    return null;
  }
}
