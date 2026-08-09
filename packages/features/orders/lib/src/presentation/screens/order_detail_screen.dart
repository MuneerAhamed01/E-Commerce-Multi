import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/order_detail_bloc.dart';
import '../widgets/cancel_return_dialog.dart';
import '../widgets/order_status_badge.dart';
import '../widgets/order_tracking_timeline.dart';

/// Order detail with line items, totals, tracking, and cancel/return actions.
class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({required this.orderId, this.detailBloc, super.key});

  final String orderId;

  /// Optional override for tests; defaults to `getIt<OrderDetailBloc>()`.
  final OrderDetailBloc? detailBloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          (detailBloc ?? getIt<OrderDetailBloc>())
            ..add(OrderDetailStarted(orderId)),
      child: const _OrderDetailView(),
    );
  }
}

class _OrderDetailView extends StatelessWidget {
  const _OrderDetailView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order detail')),
      body: BlocConsumer<OrderDetailBloc, OrderDetailState>(
        listenWhen: (previous, current) {
          if (current is! OrderDetailLoaded) {
            return false;
          }
          return current.actionError != null;
        },
        listener: (context, state) {
          if (state is OrderDetailLoaded && state.actionError != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.actionError!)));
          }
        },
        builder: (context, state) {
          return switch (state) {
            OrderDetailInitial() ||
            OrderDetailLoading() => const Center(child: AppLoadingIndicator()),
            OrderDetailError(:final message) => AppErrorState(
              title: 'Could not load order',
              message: message,
              onRetry: () => context.read<OrderDetailBloc>().add(
                const OrderDetailRetried(),
              ),
            ),
            OrderDetailLoaded(
              :final order,
              :final events,
              :final isActionInFlight,
            ) =>
              ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          order.orderNumber,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      OrderStatusBadge(status: order.status),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Placed ${_formatDate(order.createdAt)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Items', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  for (final item in order.items) ...[
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(item.productName),
                      subtitle: Text(
                        'Qty ${item.quantity}'
                        '${item.variantLabel == null ? '' : ' · ${item.variantLabel}'}',
                      ),
                      trailing: Text(Formatters.currency(item.lineTotal)),
                    ),
                    const Divider(height: 1),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Shipping address',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(_formatAddress(order.shippingAddress)),
                  if (order.shippingMethodLabel != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text('Shipping: ${order.shippingMethodLabel}'),
                  ],
                  if (order.paymentMethodLabel != null) ...[
                    Text('Payment: ${order.paymentMethodLabel}'),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Totals',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _TotalRow(label: 'Subtotal', value: order.subtotal),
                  _TotalRow(label: 'Shipping', value: order.shipping),
                  _TotalRow(label: 'Tax', value: order.tax),
                  _TotalRow(
                    label: 'Total',
                    value: order.total,
                    emphasize: true,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Tracking',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  OrderTrackingTimeline(events: events),
                  const SizedBox(height: AppSpacing.xl),
                  if (order.canCancel)
                    AppButton(
                      label: 'Cancel order',
                      variant: AppButtonVariant.destructive,
                      isFullWidth: true,
                      isLoading: isActionInFlight,
                      onPressed: isActionInFlight
                          ? null
                          : () => _onCancel(context),
                    ),
                  if (order.canRequestReturn) ...[
                    if (order.canCancel) const SizedBox(height: AppSpacing.sm),
                    AppButton(
                      label: 'Request return',
                      isFullWidth: true,
                      isLoading: isActionInFlight,
                      onPressed: isActionInFlight
                          ? null
                          : () => _onReturn(context),
                    ),
                  ],
                ],
              ),
          };
        },
      ),
    );
  }

  Future<void> _onCancel(BuildContext context) async {
    final reason = await CancelReturnDialog.show(
      context,
      title: 'Cancel this order?',
      message: 'Cancellation is only available before shipping.',
      confirmLabel: 'Cancel order',
      reasons: CancelReturnDialog.cancelReasons,
      destructive: true,
    );
    if (reason == null || !context.mounted) {
      return;
    }
    context.read<OrderDetailBloc>().add(OrderDetailCancelRequested(reason));
  }

  Future<void> _onReturn(BuildContext context) async {
    final reason = await CancelReturnDialog.show(
      context,
      title: 'Request a return?',
      message: 'We will review your return for this delivered order.',
      confirmLabel: 'Request return',
      reasons: CancelReturnDialog.returnReasons,
    );
    if (reason == null || !context.mounted) {
      return;
    }
    context.read<OrderDetailBloc>().add(OrderDetailReturnRequested(reason));
  }

  static String _formatDate(DateTime value) {
    final local = value.toLocal();
    return '${local.year}-'
        '${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')}';
  }

  static String _formatAddress(Address address) {
    final parts = <String>[
      if (address.label != null && address.label!.isNotEmpty) address.label!,
      address.line1,
      if (address.line2 != null && address.line2!.isNotEmpty) address.line2!,
      '${address.city}, ${address.state} ${address.postalCode}',
      address.countryCode,
    ];
    return parts.join('\n');
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final Money value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final style = emphasize
        ? Theme.of(context).textTheme.titleSmall
        : Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(Formatters.currency(value), style: style),
        ],
      ),
    );
  }
}
