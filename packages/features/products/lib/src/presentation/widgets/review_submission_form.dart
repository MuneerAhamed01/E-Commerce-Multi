import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Inline form for submitting a product review.
class ReviewSubmissionForm extends StatefulWidget {
  const ReviewSubmissionForm({
    required this.isSubmitting,
    required this.onSubmit,
    this.errorText,
    super.key,
  });

  final bool isSubmitting;
  final String? errorText;
  final void Function({
    required int rating,
    required String title,
    required String body,
  })
  onSubmit;

  @override
  State<ReviewSubmissionForm> createState() => _ReviewSubmissionFormState();
}

class _ReviewSubmissionFormState extends State<ReviewSubmissionForm> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  int _rating = 5;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Write a review', style: textTheme.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.xs,
          children: [
            for (var star = 1; star <= 5; star++)
              IconButton(
                onPressed: widget.isSubmitting
                    ? null
                    : () => setState(() => _rating = star),
                icon: Icon(
                  star <= _rating ? Icons.star_rounded : Icons.star_outline,
                ),
              ),
          ],
        ),
        AppTextField(
          controller: _titleController,
          label: 'Title',
          enabled: !widget.isSubmitting,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppTextField(
          controller: _bodyController,
          label: 'Review',
          maxLines: 4,
          enabled: !widget.isSubmitting,
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            widget.errorText!,
            style: textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        AppButton(
          label: 'Submit review',
          isLoading: widget.isSubmitting,
          isFullWidth: true,
          onPressed: widget.isSubmitting
              ? null
              : () => widget.onSubmit(
                  rating: _rating,
                  title: _titleController.text,
                  body: _bodyController.text,
                ),
        ),
      ],
    );
  }
}
