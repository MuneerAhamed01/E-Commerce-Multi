import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_onboarding_seen.dart';
import '../bloc/auth_bloc.dart';

/// Where splash should send the user after session resolve.
enum SplashDestination { onboarding, login, home, adminDashboard, adminLogin }

final class SplashState extends Equatable {
  const SplashState({this.destination});

  final SplashDestination? destination;

  @override
  List<Object?> get props => [destination];
}

final class SplashCubit extends Cubit<SplashState> {
  SplashCubit({
    required this.authBloc,
    required this.getOnboardingSeen,
    required this.isAdminApp,
  }) : super(const SplashState());

  final AuthBloc authBloc;
  final GetOnboardingSeen getOnboardingSeen;
  final bool isAdminApp;

  Future<void> resolve() async {
    // Ensure session restore has run.
    if (authBloc.state is AuthInitial) {
      authBloc.add(const AuthStarted());
      await authBloc.stream.firstWhere(
        (state) => state is! AuthInitial && state is! AuthLoading,
      );
    } else if (authBloc.state is AuthLoading) {
      await authBloc.stream.firstWhere((state) => state is! AuthLoading);
    }

    final authState = authBloc.state;
    if (authState is AuthAuthenticated) {
      emit(
        SplashState(
          destination: isAdminApp
              ? (authState.session.user.role.isAdminLike
                    ? SplashDestination.adminDashboard
                    : SplashDestination.adminLogin)
              : SplashDestination.home,
        ),
      );
      return;
    }

    if (isAdminApp) {
      emit(const SplashState(destination: SplashDestination.adminLogin));
      return;
    }

    final seenResult = await getOnboardingSeen(const NoParams());
    final seen = seenResult.valueOrNull ?? false;
    emit(
      SplashState(
        destination: seen
            ? SplashDestination.login
            : SplashDestination.onboarding,
      ),
    );
  }
}
