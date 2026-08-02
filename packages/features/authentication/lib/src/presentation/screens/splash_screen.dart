import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/usecases/get_onboarding_seen.dart';
import '../bloc/auth_bloc.dart';
import '../cubit/splash_cubit.dart';
import '../routing/auth_routes.dart';

/// Tenant-branded splash that resolves session → next route.
class SplashScreen extends StatelessWidget {
  const SplashScreen({
    required this.isAdminApp,
    this.getOnboardingSeen,
    super.key,
  });

  final bool isAdminApp;
  final GetOnboardingSeen? getOnboardingSeen;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) {
        final cubit = SplashCubit(
          authBloc: ctx.read<AuthBloc>(),
          getOnboardingSeen: getOnboardingSeen ?? getIt<GetOnboardingSeen>(),
          isAdminApp: isAdminApp,
        );
        // Defer resolve until after BlocListener is subscribed.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          cubit.resolve();
        });
        return cubit;
      },
      child: const _SplashView(),
    );
  }
}

class _SplashView extends StatelessWidget {
  const _SplashView();

  @override
  Widget build(BuildContext context) {
    final tenant = getIt.isRegistered<TenantConfig>()
        ? getIt<TenantConfig>()
        : null;

    return BlocListener<SplashCubit, SplashState>(
      listenWhen: (prev, next) =>
          next.destination != null && prev.destination != next.destination,
      listener: (context, state) {
        final destination = state.destination;
        if (destination == null) {
          return;
        }
        final path = switch (destination) {
          SplashDestination.onboarding => AuthRoutes.onboardingPath,
          SplashDestination.login => AuthRoutes.loginPath,
          SplashDestination.home => SystemRoutes.storefrontHomePath,
          SplashDestination.adminDashboard => SystemRoutes.adminDashboardPath,
          SplashDestination.adminLogin => AuthRoutes.adminLoginPath,
        };
        context.go(path);
      },
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                tenant?.displayName ?? 'Commerce',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const AppLoadingIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
