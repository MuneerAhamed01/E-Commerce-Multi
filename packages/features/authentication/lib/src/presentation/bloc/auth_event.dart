part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Cold-start: restore persisted session (if any).
final class AuthStarted extends AuthEvent {
  const AuthStarted();
}

final class AuthLoginSubmitted extends AuthEvent {
  const AuthLoginSubmitted({
    required this.email,
    required this.password,
    this.requireAdmin = false,
  });

  final String email;
  final String password;
  final bool requireAdmin;

  @override
  List<Object?> get props => [email, password, requireAdmin];
}

final class AuthRegisterSubmitted extends AuthEvent {
  const AuthRegisterSubmitted({
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

final class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

/// Clears a one-shot auth error after the UI has shown it.
final class AuthErrorCleared extends AuthEvent {
  const AuthErrorCleared();
}
