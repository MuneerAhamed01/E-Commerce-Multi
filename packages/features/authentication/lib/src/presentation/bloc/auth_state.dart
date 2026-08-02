part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Before [AuthStarted] finishes.
final class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Session restore / login / register / logout in flight.
final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.session);

  final AuthSession session;

  @override
  List<Object?> get props => [session];
}

final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated({this.errorMessage});

  /// Optional inline error from the last login/register attempt.
  final String? errorMessage;

  @override
  List<Object?> get props => [errorMessage];
}
