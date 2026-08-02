import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';

final class RegisterState extends Equatable {
  const RegisterState({
    this.displayName = '',
    this.email = '',
    this.phone = '',
    this.password = '',
    this.acceptedTerms = false,
    this.displayNameError,
    this.emailError,
    this.phoneError,
    this.passwordError,
    this.termsError,
  });

  final String displayName;
  final String email;
  final String phone;
  final String password;
  final bool acceptedTerms;
  final String? displayNameError;
  final String? emailError;
  final String? phoneError;
  final String? passwordError;
  final String? termsError;

  RegisterState copyWith({
    String? displayName,
    String? email,
    String? phone,
    String? password,
    bool? acceptedTerms,
    String? displayNameError,
    String? emailError,
    String? phoneError,
    String? passwordError,
    String? termsError,
    bool clearDisplayNameError = false,
    bool clearEmailError = false,
    bool clearPhoneError = false,
    bool clearPasswordError = false,
    bool clearTermsError = false,
  }) {
    return RegisterState(
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      acceptedTerms: acceptedTerms ?? this.acceptedTerms,
      displayNameError: clearDisplayNameError
          ? null
          : (displayNameError ?? this.displayNameError),
      emailError: clearEmailError ? null : (emailError ?? this.emailError),
      phoneError: clearPhoneError ? null : (phoneError ?? this.phoneError),
      passwordError: clearPasswordError
          ? null
          : (passwordError ?? this.passwordError),
      termsError: clearTermsError ? null : (termsError ?? this.termsError),
    );
  }

  @override
  List<Object?> get props => [
    displayName,
    email,
    phone,
    password,
    acceptedTerms,
    displayNameError,
    emailError,
    phoneError,
    passwordError,
    termsError,
  ];
}

final class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit({required this.authBloc}) : super(const RegisterState());

  final AuthBloc authBloc;

  void displayNameChanged(String value) {
    emit(state.copyWith(displayName: value, clearDisplayNameError: true));
  }

  void emailChanged(String value) {
    emit(state.copyWith(email: value, clearEmailError: true));
  }

  void phoneChanged(String value) {
    emit(state.copyWith(phone: value, clearPhoneError: true));
  }

  void passwordChanged(String value) {
    emit(state.copyWith(password: value, clearPasswordError: true));
  }

  void termsChanged(bool value) {
    emit(state.copyWith(acceptedTerms: value, clearTermsError: true));
  }

  void submit() {
    final displayNameError = Validators.required(
      state.displayName,
      fieldName: 'Name',
    );
    final emailError = Validators.email(state.email);
    final phoneError = Validators.phone(state.phone);
    final passwordError = Validators.passwordStrength(state.password);
    final termsError = state.acceptedTerms
        ? null
        : 'Please accept the terms to continue';

    if (displayNameError != null ||
        emailError != null ||
        phoneError != null ||
        passwordError != null ||
        termsError != null) {
      emit(
        state.copyWith(
          displayNameError: displayNameError,
          emailError: emailError,
          phoneError: phoneError,
          passwordError: passwordError,
          termsError: termsError,
        ),
      );
      return;
    }

    authBloc.add(
      AuthRegisterSubmitted(
        displayName: state.displayName.trim(),
        email: state.email.trim(),
        phone: state.phone.trim(),
        password: state.password,
      ),
    );
  }
}
