import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/checkout_bloc.dart';
import '../bloc/checkout_event.dart';
import '../bloc/checkout_state.dart';
import '../routing/checkout_routes.dart';

/// Checkout step 2 — review totals and place order.
class CheckoutReviewScreen extends StatelessWidget {
  const CheckoutReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review order')),
      body: BlocConsumer<CheckoutBloc, CheckoutState>(
        listenWhen: (prev, next) =>
            next is CheckoutPlaced && prev is! CheckoutPlaced,
        listener: (context, state) {
          if (state is CheckoutPlaced) {
            context.go(CheckoutRoutes.confirmationPath(state.orderId));
          }
        },
        builder: (context, state) {
          final isPlacing = state is CheckoutPlacing;
          final ready = switch (state) {
            CheckoutReady() => state,
            CheckoutPlacing(:final ready) => ready,
            _ => null,
          };
          if (ready == null) {
            return const Center(child: AppLoadingIndicator());
          }

          final address = ready.effectiveAddress;
          final shipping = ready.selectedShipping;
          final payment = ready.selectedPayment;
          final pricing = ready.cartSummary.pricing;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: AppStepperHeader(
                  steps: CheckoutRoutes.stepperLabels,
                  currentStep: 2,
                ),
              ),
              if (ready.stepError != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    ready.stepError!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      'Items',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    for (final item in ready.cartSummary.cart.items)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(item.productName),
                        subtitle: Text(
                          '${item.variantLabel} × ${item.quantity}',
                        ),
                        trailing: Text(Formatters.currency(item.lineTotal)),
                      ),
                    const Divider(),
                    if (address != null) ...[
                      Text(
                        'Ship to',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      AppAddressCard(address: address),
                      const SizedBox(height: 16),
                    ],
                    if (shipping != null)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Shipping'),
                        subtitle: Text(
                          '${shipping.name} · ${shipping.etaLabel}',
                        ),
                        trailing: Text(
                          Formatters.currency(
                            ready.shippingCost ?? shipping.cost,
                          ),
                        ),
                      ),
                    if (payment != null)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Payment'),
                        subtitle: Text(payment.displayLabel),
                      ),
                    const Divider(),
                    _TotalRow(
                      label: 'Subtotal',
                      value: Formatters.currency(pricing.subtotal),
                    ),
                    if (!pricing.discount.isZero)
                      _TotalRow(
                        label: 'Discount',
                        value: '-${Formatters.currency(pricing.discount)}',
                      ),
                    _TotalRow(
                      label: 'Shipping',
                      value: Formatters.currency(
                        ready.shippingCost ?? Money.zero('USD'),
                      ),
                    ),
                    _TotalRow(
                      label: 'Tax',
                      value: Formatters.currency(pricing.taxPlaceholder),
                    ),
                    const SizedBox(height: 8),
                    _TotalRow(
                      label: 'Total',
                      value: Formatters.currency(ready.orderTotal),
                      emphasize: true,
                    ),
                  ],
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: AppButton(
                    label: 'Place order',
                    isFullWidth: true,
                    isLoading: isPlacing,
                    onPressed: isPlacing
                        ? null
                        : () => context.read<CheckoutBloc>().add(
                            const CheckoutPlaceOrderRequested(),
                          ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final style = emphasize
        ? Theme.of(context).textTheme.titleMedium
        : Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }
}
