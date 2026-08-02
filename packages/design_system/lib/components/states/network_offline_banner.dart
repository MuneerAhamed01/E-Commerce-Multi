import 'package:flutter/material.dart';

import '../../theme/theme_extensions.dart';
import '../../tokens/app_spacing.dart';

/// A persistent banner shown when connectivity is lost, per
/// docs/08_COMPONENT_LIBRARY.md §10 (`NetworkOfflineBanner`). Rendered as a
/// global app-shell overlay in both apps, driven by `core`'s `NetworkInfo`.
///
/// This widget itself takes no connectivity dependency - the app shell
/// decides *when* to show it (typically via a `StreamBuilder` over
/// `NetworkInfo.onConnectivityChanged`, added when that stream is wired up)
/// and mounts/unmounts it accordingly.
///
/// ```dart
/// if (!isOnline) const AppNetworkOfflineBanner(),
/// ```
class AppNetworkOfflineBanner extends StatelessWidget {
  const AppNetworkOfflineBanner({this.message = "You're offline", super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    final semantic = context.semanticColors;

    return Material(
      color: semantic.warningContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, size: 16, color: semantic.onWarningContainer),
            const SizedBox(width: AppSpacing.sm),
            Text(
              message,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: semantic.onWarningContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
