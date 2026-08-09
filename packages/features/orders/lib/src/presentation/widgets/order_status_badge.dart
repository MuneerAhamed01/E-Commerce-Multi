import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/order_status.dart';

/// Color-coded status chip using semantic / ColorScheme tokens (no hex).
class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({required this.status, super.key});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final semantic = context.semanticColors;
    final (Color bg, Color fg) = switch (status) {
      OrderStatus.placed => (semantic.infoContainer, semantic.onInfoContainer),
      OrderStatus.processing => (
        semantic.warningContainer,
        semantic.onWarningContainer,
      ),
      OrderStatus.shipped => (semantic.infoContainer, semantic.onInfoContainer),
      OrderStatus.delivered => (
        semantic.successContainer,
        semantic.onSuccessContainer,
      ),
      OrderStatus.cancelled => (scheme.errorContainer, scheme.onErrorContainer),
      OrderStatus.returnRequested => (
        semantic.warningContainer,
        semantic.onWarningContainer,
      ),
      OrderStatus.returned => (
        scheme.surfaceContainerHighest,
        scheme.onSurfaceVariant,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs + 1,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.xs),
      ),
      child: Text(
        status.displayLabel,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
