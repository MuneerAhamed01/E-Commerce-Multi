import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/order_list_bloc.dart';
import '../routing/order_routes.dart';
import '../widgets/order_list_tile.dart';

/// Authenticated customer's order history (newest first).
class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({this.listBloc, super.key});

  /// Optional override for tests; defaults to `getIt<OrderListBloc>()`.
  final OrderListBloc? listBloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          (listBloc ?? getIt<OrderListBloc>())..add(const OrderListStarted()),
      child: const _OrderHistoryView(),
    );
  }
}

class _OrderHistoryView extends StatelessWidget {
  const _OrderHistoryView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My orders')),
      body: BlocBuilder<OrderListBloc, OrderListState>(
        builder: (context, state) {
          return switch (state) {
            OrderListInitial() ||
            OrderListLoading() => const Center(child: AppLoadingIndicator()),
            OrderListEmpty() => AppEmptyState(
              title: 'No orders yet',
              message: 'When you place an order, it will show up here.',
              ctaLabel: 'Start Shopping',
              onCtaPressed: () => context.go('/products'),
            ),
            OrderListError(:final message) => AppErrorState(
              title: 'Could not load orders',
              message: message,
              onRetry: () =>
                  context.read<OrderListBloc>().add(const OrderListRetried()),
            ),
            OrderListLoaded(:final orders) => ListView.separated(
              itemCount: orders.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final order = orders[index];
                return OrderListTile(
                  order: order,
                  onTap: () => context.push(OrderRoutes.detailPath(order.id)),
                );
              },
            ),
          };
        },
      ),
    );
  }
}
