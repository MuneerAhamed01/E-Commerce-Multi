import 'package:flutter/material.dart';

import '../../tokens/app_spacing.dart';
import '../states/app_empty_state.dart';

/// Shared 404 / unmatched-route screen (docs/09_ROUTING_PLAN.md §7).
///
/// Distinct from a domain-level "not found" rendered inside a matched
/// feature screen — this only appears via `GoRouter.errorBuilder`.
///
/// ```dart
/// GoRouter(
///   errorBuilder: (context, state) => AppNotFoundScreen(
///     onGoHome: () => context.go('/home'),
///   ),
/// );
/// ```
class AppNotFoundScreen extends StatelessWidget {
  const AppNotFoundScreen({
    required this.onGoHome,
    this.homeLabel = 'Go home',
    super.key,
  });

  /// Navigates to the app's default landing (`/home` or `/admin/dashboard`).
  final VoidCallback onGoHome;

  final String homeLabel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Center(
            child: AppEmptyState(
              title: 'Page not found',
              message: 'This link is broken or the page no longer exists.',
              ctaLabel: homeLabel,
              onCtaPressed: onGoHome,
            ),
          ),
        ),
      ),
    );
  }
}
