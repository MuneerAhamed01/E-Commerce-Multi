import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/order.dart';
import 'order_status_badge.dart';

/// Summary row for order history lists.
class OrderListTile extends StatelessWidget {
  const OrderListTile({required this.order, this.onTap, super.key});

  final Order order;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateLabel =
        '${order.createdAt.toLocal().year}-'
        '${order.createdAt.toLocal().month.toString().padLeft(2, '0')}-'
        '${order.createdAt.toLocal().day.toString().padLeft(2, '0')}';

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(order.orderNumber, style: theme.textTheme.titleSmall),
          ),
          OrderStatusBadge(status: order.status),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.xs),
        child: Text(
          '$dateLabel · ${order.items.length} item'
          '${order.items.length == 1 ? '' : 's'} · '
          '${Formatters.currency(order.total)}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
      trailing: onTap == null
          ? null
          : Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurfaceVariant,
            ),
    );
  }
}
