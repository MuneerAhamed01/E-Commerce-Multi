import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/usecases/reset_password.dart';
import '../cubit/reset_password_cubit.dart';
import '../routing/auth_routes.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({
    required this.email,
    this.isAdminApp = false,
    super.key,
  });

  final String email;
  final bool isAdminApp;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ResetPasswordCubit(
        resetPassword: getIt<ResetPassword>(),
        email: email,
      ),
      child: _ResetPasswordView(isAdminApp: isAdminApp),
    );
  }
}

class _ResetPasswordView extends StatelessWidget {
  const _ResetPasswordView({required this.isAdminApp});

  final bool isAdminApp;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ResetPasswordCubit, ResetPasswordState>(
      listenWhen: (prev, next) =>
          next.status == ResetPasswordStatus.success &&
          prev.status != ResetPasswordStatus.success,
      listener: (context, state) {
        context.go(
          isAdminApp ? AuthRoutes.adminLoginPath : AuthRoutes.loginPath,
        );
      },
      builder: (context, state) {
        final cubit = context.read<ResetPasswordCubit>();
        final loading = state.status == ResetPasswordStatus.submitting;

        return Scaffold(
          appBar: AppBar(title: const Text('Reset password')),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Choose a new password for your account.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      if (state.errorMessage != null) ...[
                        AppInlineErrorBanner(message: state.errorMessage!),
                        const SizedBox(height: AppSpacing.md),
                      ],
                      AppAuthTextField(
                        label: 'New password',
                        obscureText: true,
                        autofillHints: const [AutofillHints.newPassword],
                        errorText: state.passwordError,
                        onChanged: cubit.passwordChanged,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppPasswordStrengthIndicator(password: state.password),
                      const SizedBox(height: AppSpacing.md),
                      AppAuthTextField(
                        label: 'Confirm password',
                        obscureText: true,
                        errorText: state.confirmError,
                        onChanged: cubit.confirmChanged,
                        onSubmitted: (_) => cubit.submit(),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AppButton(
                        label: 'Update password',
                        isFullWidth: true,
                        isLoading: loading,
                        onPressed: loading ? null : cubit.submit,
                      ),
                    ],
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
