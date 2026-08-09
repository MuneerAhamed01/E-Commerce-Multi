import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:orders/orders.dart';

/// Post-place confirmation — stack replaced via `context.go`.
class CheckoutConfirmationScreen extends StatefulWidget {
  const CheckoutConfirmationScreen({required this.orderId, super.key});

  final String orderId;

  @override
  State<CheckoutConfirmationScreen> createState() =>
      _CheckoutConfirmationScreenState();
}

class _CheckoutConfirmationScreenState
    extends State<CheckoutConfirmationScreen> {
  Order? _order;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await getIt<GetOrder>()(GetOrderParams(widget.orderId));
    if (!mounted) {
      return;
    }
    setState(() {
      _loading = false;
      if (result.isSuccess) {
        _order = result.valueOrNull;
      } else {
        _error = result.failureOrNull?.message ?? 'Order not found';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order confirmed')),
      body: _loading
          ? const Center(child: AppLoadingIndicator())
          : _error != null
          ? AppErrorState(
              title: 'Could not load order',
              message: _error!,
              onRetry: () {
                setState(() {
                  _loading = true;
                  _error = null;
                });
                _load();
              },
            )
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Thank you!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Order ${_order?.orderNumber ?? widget.orderId} is placed.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Order ID: ${widget.orderId}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (_order != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Total: ${Formatters.currency(_order!.total)}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                  const SizedBox(height: 24),
                  Text(
                    'View order details will arrive in Phase 15.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  AppButton(
                    label: 'Continue shopping',
                    isFullWidth: true,
                    onPressed: () => context.go('/'),
                  ),
                ],
              ),
            ),
    );
  }
}
