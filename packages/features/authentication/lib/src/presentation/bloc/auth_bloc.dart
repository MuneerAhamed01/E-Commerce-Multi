import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/auth_session.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/logout_user.dart';
import '../../domain/usecases/refresh_session.dart';
import '../../domain/usecases/register_user.dart';
import '../../domain/usecases/restore_session.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// Session lifecycle bloc (lazy singleton at app root).
final class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required this.restoreSession,
    required this.loginUser,
    required this.registerUser,
    required this.logoutUser,
    required this.refreshSession,
  }) : super(const AuthInitial()) {
    on<AuthStarted>(_onStarted);
    on<AuthLoginSubmitted>(_onLogin);
    on<AuthRegisterSubmitted>(_onRegister);
    on<AuthLogoutRequested>(_onLogout);
    on<AuthErrorCleared>(_onErrorCleared);
  }

  final RestoreSession restoreSession;
  final LoginUser loginUser;
  final RegisterUser registerUser;
  final LogoutUser logoutUser;
  final RefreshSession refreshSession;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final restored = await restoreSession(const NoParams());
    await restored.fold(
      onFailure: (_) async {
        emit(const AuthUnauthenticated());
      },
      onSuccess: (session) async {
        if (session == null) {
          emit(const AuthUnauthenticated());
          return;
        }
        if (session.isExpired) {
          final refreshed = await refreshSession(const NoParams());
          refreshed.fold(
            onFailure: (_) => emit(const AuthUnauthenticated()),
            onSuccess: (value) {
              if (value == null) {
                emit(const AuthUnauthenticated());
              } else {
                emit(AuthAuthenticated(value));
              }
            },
          );
          return;
        }
        emit(AuthAuthenticated(session));
      },
    );
  }

  Future<void> _onLogin(
    AuthLoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await loginUser(
      LoginParams(
        email: event.email,
        password: event.password,
        requireAdmin: event.requireAdmin,
      ),
    );
    result.fold(
      onFailure: (failure) {
        emit(AuthUnauthenticated(errorMessage: _mapFailure(failure)));
      },
      onSuccess: (session) => emit(AuthAuthenticated(session)),
    );
  }

  Future<void> _onRegister(
    AuthRegisterSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await registerUser(
      RegisterParams(
        displayName: event.displayName,
        email: event.email,
        phone: event.phone,
        password: event.password,
      ),
    );
    result.fold(
      onFailure: (failure) {
        emit(AuthUnauthenticated(errorMessage: _mapFailure(failure)));
      },
      onSuccess: (session) => emit(AuthAuthenticated(session)),
    );
  }

  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    await logoutUser(const NoParams());
    emit(const AuthUnauthenticated());
  }

  void _onErrorCleared(AuthErrorCleared event, Emitter<AuthState> emit) {
    if (state is AuthUnauthenticated) {
      emit(const AuthUnauthenticated());
    }
  }

  String _mapFailure(Failure failure) {
    return switch (failure) {
      UnauthorizedFailure(:final message) =>
        message ?? 'Invalid email or password',
      ValidationFailure(:final fieldErrors, :final message) =>
        fieldErrors.values.firstOrNull ?? message ?? 'Validation failed',
      NetworkFailure() => 'Network error. Please try again.',
      ServerFailure() => 'Something went wrong. Please try again.',
      _ => failure.message ?? 'Something went wrong. Please try again.',
    };
  }
}
