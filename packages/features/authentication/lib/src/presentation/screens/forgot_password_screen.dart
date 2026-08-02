import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/request_password_reset.dart';
import '../cubit/forgot_password_cubit.dart';
import '../routing/auth_routes.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({this.isAdminApp = false, super.key});

  final bool isAdminApp;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ForgotPasswordCubit(
        requestPasswordReset: getIt<RequestPasswordReset>(),
      ),
      child: _ForgotPasswordView(isAdminApp: isAdminApp),
    );
  }
}

class _ForgotPasswordView extends StatelessWidget {
  const _ForgotPasswordView({required this.isAdminApp});

  final bool isAdminApp;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
      listenWhen: (prev, next) =>
          next.status == ForgotPasswordStatus.success &&
          prev.status != ForgotPasswordStatus.success,
      listener: (context, state) {
        final email = Uri.encodeComponent(state.email.trim());
        final base = isAdminApp
            ? AuthRoutes.adminVerifyOtpPath
            : AuthRoutes.verifyOtpPath;
        context.go(
          '$base?${AuthRoutes.emailQueryKey}=$email'
          '&${AuthRoutes.purposeQueryKey}=${OtpPurpose.passwordReset.name}',
        );
      },
      builder: (context, state) {
        final cubit = context.read<ForgotPasswordCubit>();
        final loading = state.status == ForgotPasswordStatus.submitting;

        return Scaffold(
          appBar: AppBar(title: const Text('Forgot password')),
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
                        'Enter your email and we\'ll send a verification code.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      if (state.errorMessage != null) ...[
                        AppInlineErrorBanner(message: state.errorMessage!),
                        const SizedBox(height: AppSpacing.md),
                      ],
                      AppAuthTextField(
                        label: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        errorText: state.emailError,
                        onChanged: cubit.emailChanged,
                        onSubmitted: (_) => cubit.submit(),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AppButton(
                        label: 'Send code',
                        isFullWidth: true,
                        isLoading: loading,
                        onPressed: loading ? null : cubit.submit,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppButton(
                        label: 'Back to sign in',
                        variant: AppButtonVariant.text,
                        isFullWidth: true,
                        onPressed: () => context.go(
                          isAdminApp
                              ? AuthRoutes.adminLoginPath
                              : AuthRoutes.loginPath,
                        ),
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
