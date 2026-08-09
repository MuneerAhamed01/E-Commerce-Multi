import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Reason selection + confirm dialog for cancel or return (RESP-FORM modal).
class CancelReturnDialog extends StatefulWidget {
  const CancelReturnDialog({
    required this.title,
    required this.confirmLabel,
    required this.reasons,
    this.destructive = false,
    this.message,
    super.key,
  });

  final String title;
  final String? message;
  final String confirmLabel;
  final List<String> reasons;
  final bool destructive;

  /// Shows the dialog; returns the selected reason, or `null` if dismissed.
  static Future<String?> show(
    BuildContext context, {
    required String title,
    required String confirmLabel,
    required List<String> reasons,
    String? message,
    bool destructive = false,
  }) {
    return showDialog<String>(
      context: context,
      builder: (_) => CancelReturnDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        reasons: reasons,
        destructive: destructive,
      ),
    );
  }

  static const List<String> cancelReasons = [
    'Changed my mind',
    'Found a better price',
    'Ordered by mistake',
    'Other',
  ];

  static const List<String> returnReasons = [
    'Item damaged',
    'Wrong item received',
    'Does not match description',
    'Other',
  ];

  @override
  State<CancelReturnDialog> createState() => _CancelReturnDialogState();
}

class _CancelReturnDialogState extends State<CancelReturnDialog> {
  String? _selected;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.message != null) ...[
              Text(widget.message!),
              const SizedBox(height: AppSpacing.md),
            ],
            Text('Reason', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final reason in widget.reasons)
                  ChoiceChip(
                    label: Text(reason),
                    selected: _selected == reason,
                    onSelected: (_) => setState(() => _selected = reason),
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        AppButton(
          label: 'Keep order',
          variant: AppButtonVariant.text,
          onPressed: () => Navigator.of(context).pop(),
        ),
        AppButton(
          label: widget.confirmLabel,
          variant: widget.destructive
              ? AppButtonVariant.destructive
              : AppButtonVariant.primary,
          onPressed: _selected == null
              ? null
              : () => Navigator.of(context).pop(_selected),
        ),
      ],
    );
  }
}
