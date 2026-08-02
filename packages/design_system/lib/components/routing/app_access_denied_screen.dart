import 'package:flutter/material.dart';

import '../../tokens/app_spacing.dart';
import '../states/app_empty_state.dart';

/// Admin access-denied landing (docs/09_ROUTING_PLAN.md §3.2 /
/// `/admin/access-denied`). Shown when a role/permission check fails —
/// distinct from a 404 for a disabled feature.
class AppAccessDeniedScreen extends StatelessWidget {
  const AppAccessDeniedScreen({
    required this.onGoHome,
    this.homeLabel = 'Back to dashboard',
    super.key,
  });

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
              title: 'Access denied',
              message: 'Your role does not include permission for this page.',
              ctaLabel: homeLabel,
              onCtaPressed: onGoHome,
            ),
          ),
        ),
      ),
    );
  }
}
