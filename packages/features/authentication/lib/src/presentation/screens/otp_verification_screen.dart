import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../data/mock/auth_demo_credentials.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/verify_otp.dart';
import '../cubit/otp_cubit.dart';
import '../routing/auth_routes.dart';

class OtpVerificationScreen extends StatelessWidget {
  const OtpVerificationScreen({
    required this.email,
    required this.purpose,
    this.isAdminApp = false,
    super.key,
  });

  final String email;
  final OtpPurpose purpose;
  final bool isAdminApp;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OtpCubit(
        verifyOtp: getIt<VerifyOtp>(),
        email: email,
        purpose: purpose,
      ),
      child: _OtpView(isAdminApp: isAdminApp, email: email, purpose: purpose),
    );
  }
}

class _OtpView extends StatelessWidget {
  const _OtpView({
    required this.isAdminApp,
    required this.email,
    required this.purpose,
  });

  final bool isAdminApp;
  final String email;
  final OtpPurpose purpose;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OtpCubit, OtpState>(
      listenWhen: (prev, next) =>
          next.status == OtpStatus.success && prev.status != OtpStatus.success,
      listener: (context, state) {
        final encoded = Uri.encodeComponent(email);
        if (purpose == OtpPurpose.passwordReset) {
          final base = isAdminApp
              ? AuthRoutes.adminResetPasswordPath
              : AuthRoutes.resetPasswordPath;
          context.go('$base?${AuthRoutes.emailQueryKey}=$encoded');
          return;
        }
        context.go(SystemRoutes.storefrontHomePath);
      },
      builder: (context, state) {
        final loading = state.status == OtpStatus.submitting;
        return Scaffold(
          appBar: AppBar(title: const Text('Verify code')),
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
                        'Enter the 6-digit code sent to $email',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      if (getIt.isRegistered<AppConfig>() &&
                          getIt<AppConfig>().environment !=
                              Environment.prod) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Dev OTP: ${AuthDemoCredentials.mockOtp}',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      if (state.errorMessage != null) ...[
                        AppInlineErrorBanner(message: state.errorMessage!),
                        const SizedBox(height: AppSpacing.md),
                      ],
                      Center(
                        child: AppOtpInputRow(
                          hasError: state.hasError,
                          onCompleted: (code) {
                            if (!loading) {
                              context.read<OtpCubit>().submit(code);
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      if (loading) const AppLoadingIndicator(),
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
