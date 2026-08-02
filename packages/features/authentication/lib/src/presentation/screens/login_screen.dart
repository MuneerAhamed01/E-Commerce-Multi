import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/auth_bloc.dart';
import '../cubit/login_cubit.dart';
import '../routing/auth_routes.dart';

/// Shared login UI for storefront (`/login`) and admin (`/admin/login`).
class LoginScreen extends StatelessWidget {
  const LoginScreen({
    this.requireAdmin = false,
    this.isAdminApp = false,
    super.key,
  });

  final bool requireAdmin;
  final bool isAdminApp;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => LoginCubit(
        authBloc: ctx.read<AuthBloc>(),
        requireAdmin: requireAdmin,
      ),
      child: _LoginView(isAdminApp: isAdminApp),
    );
  }
}

class _LoginView extends StatelessWidget {
  const _LoginView({required this.isAdminApp});

  final bool isAdminApp;

  @override
  Widget build(BuildContext context) {
    final tenantName = getIt.isRegistered<TenantConfig>()
        ? getIt<TenantConfig>().displayName
        : 'Account';

    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (prev, next) =>
          next is AuthAuthenticated ||
          (next is AuthUnauthenticated && next.errorMessage != null),
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          final uri = GoRouterState.of(context).uri;
          final target = RouteGuard.postLoginLocation(
            app: isAdminApp ? RouteAppKind.admin : RouteAppKind.storefront,
            loginUri: uri,
          );
          context.go(target);
        }
      },
      builder: (context, authState) {
        final isLoading = authState is AuthLoading;
        final authError = authState is AuthUnauthenticated
            ? authState.errorMessage
            : null;

        return Scaffold(
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: BlocBuilder<LoginCubit, LoginState>(
                    builder: (context, form) {
                      final cubit = context.read<LoginCubit>();
                      return AutofillGroup(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              isAdminApp ? 'Admin sign in' : 'Sign in',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              isAdminApp
                                  ? 'Manage $tenantName'
                                  : 'Welcome back to $tenantName',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            if (authError != null) ...[
                              AppInlineErrorBanner(
                                message: authError,
                                onDismiss: () => context.read<AuthBloc>().add(
                                  const AuthErrorCleared(),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                            ],
                            AppAuthTextField(
                              label: 'Email',
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.email],
                              errorText: form.emailError,
                              onChanged: cubit.emailChanged,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            AppAuthTextField(
                              label: 'Password',
                              obscureText: true,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.password],
                              errorText: form.passwordError,
                              onChanged: cubit.passwordChanged,
                              onSubmitted: (_) => cubit.submit(),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Align(
                              alignment: Alignment.centerRight,
                              child: AppTextLinkButton(
                                label: 'Forgot password?',
                                onPressed: () => context.go(
                                  isAdminApp
                                      ? AuthRoutes.adminForgotPasswordPath
                                      : AuthRoutes.forgotPasswordPath,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            AppButton(
                              label: 'Sign in',
                              isFullWidth: true,
                              isLoading: isLoading,
                              onPressed: isLoading ? null : cubit.submit,
                            ),
                            if (!isAdminApp) ...[
                              const SizedBox(height: AppSpacing.md),
                              AppButton(
                                label: 'Create an account',
                                variant: AppButtonVariant.text,
                                isFullWidth: true,
                                onPressed: () =>
                                    context.go(AuthRoutes.registerPath),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
