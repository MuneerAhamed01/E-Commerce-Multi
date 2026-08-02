import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/auth_bloc.dart';
import '../cubit/register_cubit.dart';
import '../routing/auth_routes.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => RegisterCubit(authBloc: ctx.read<AuthBloc>()),
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatelessWidget {
  const _RegisterView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (prev, next) => next is AuthAuthenticated,
      listener: (context, state) {
        context.go(SystemRoutes.storefrontHomePath);
      },
      builder: (context, authState) {
        final isLoading = authState is AuthLoading;
        final authError = authState is AuthUnauthenticated
            ? authState.errorMessage
            : null;

        return Scaffold(
          appBar: AppBar(title: const Text('Create account')),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: BlocBuilder<RegisterCubit, RegisterState>(
                    builder: (context, form) {
                      final cubit = context.read<RegisterCubit>();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
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
                            label: 'Full name',
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.name],
                            errorText: form.displayNameError,
                            onChanged: cubit.displayNameChanged,
                          ),
                          const SizedBox(height: AppSpacing.md),
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
                            label: 'Phone',
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [
                              AutofillHints.telephoneNumber,
                            ],
                            errorText: form.phoneError,
                            onChanged: cubit.phoneChanged,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppAuthTextField(
                            label: 'Password',
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.newPassword],
                            errorText: form.passwordError,
                            onChanged: cubit.passwordChanged,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          AppPasswordStrengthIndicator(password: form.password),
                          const SizedBox(height: AppSpacing.md),
                          CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            value: form.acceptedTerms,
                            onChanged: (value) =>
                                cubit.termsChanged(value ?? false),
                            controlAffinity: ListTileControlAffinity.leading,
                            title: const Text(
                              'I agree to the terms of service',
                            ),
                            subtitle: form.termsError == null
                                ? null
                                : Text(
                                    form.termsError!,
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          AppButton(
                            label: 'Create account',
                            isFullWidth: true,
                            isLoading: isLoading,
                            onPressed: isLoading ? null : cubit.submit,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppButton(
                            label: 'Already have an account? Sign in',
                            variant: AppButtonVariant.text,
                            isFullWidth: true,
                            onPressed: () => context.go(AuthRoutes.loginPath),
                          ),
                        ],
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
