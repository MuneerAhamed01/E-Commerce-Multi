import 'package:flutter/material.dart';

import '../buttons/app_button.dart';

/// Visual treatment of an [AppAlertDialog]. See
/// docs/08_COMPONENT_LIBRARY.md §3.
enum AppAlertDialogVariant {
  /// Neutral confirm/cancel decision.
  standard,

  /// Confirm action is rendered with [AppButtonVariant.destructive] -
  /// delete/cancel/suspend confirmations
  /// (docs/06_DEVELOPMENT_RULES.md Rule 22).
  destructive,
}

/// A simple confirm/cancel decision dialog, per
/// docs/08_COMPONENT_LIBRARY.md §3 (`AppAlertDialog`). This is the shared
/// primitive every destructive-action confirmation in the app must use
/// (docs/06_DEVELOPMENT_RULES.md Rule 22) rather than a bespoke
/// `showDialog` call.
///
/// ```dart
/// final confirmed = await AppAlertDialog.show(
///   context,
///   title: 'Delete address?',
///   message: 'This can\'t be undone.',
///   variant: AppAlertDialogVariant.destructive,
///   confirmLabel: 'Delete',
/// );
/// if (confirmed ?? false) cubit.delete(address);
/// ```
class AppAlertDialog extends StatelessWidget {
  const AppAlertDialog({
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.variant = AppAlertDialogVariant.standard,
    super.key,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final AppAlertDialogVariant variant;

  /// Shows the dialog and resolves to `true` if confirmed, `false` if
  /// cancelled/dismissed, or `null` if dismissed via barrier tap/back
  /// button without an explicit choice.
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    AppAlertDialogVariant variant = AppAlertDialogVariant.standard,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AppAlertDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        variant: variant,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        AppButton(
          label: cancelLabel,
          variant: AppButtonVariant.text,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        AppButton(
          label: confirmLabel,
          variant: variant == AppAlertDialogVariant.destructive
              ? AppButtonVariant.destructive
              : AppButtonVariant.primary,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
  }
}
