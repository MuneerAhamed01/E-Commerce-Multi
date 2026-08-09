import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/order_tracking_event.dart';
import 'order_status_badge.dart';

/// Chronological tracking milestones for an order.
class OrderTrackingTimeline extends StatelessWidget {
  const OrderTrackingTimeline({required this.events, super.key});

  final List<OrderTrackingEvent> events;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return Text(
        'No tracking updates yet.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
    }

    final theme = Theme.of(context);
    final border = context.semanticColors.border;

    return Column(
      children: [
        for (var i = 0; i < events.length; i++) ...[
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 24,
                  child: Column(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      if (i < events.length - 1)
                        Expanded(child: Container(width: 2, color: border)),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: i < events.length - 1 ? AppSpacing.md : 0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                events[i].title,
                                style: theme.textTheme.titleSmall,
                              ),
                            ),
                            OrderStatusBadge(status: events[i].status),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          _formatWhen(events[i].occurredAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (events[i].description != null) ...[
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            events[i].description!,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  static String _formatWhen(DateTime when) {
    final local = when.toLocal();
    return '${local.year}-'
        '${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }
}
