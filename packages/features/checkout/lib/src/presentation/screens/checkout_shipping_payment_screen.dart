import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/checkout_payment_method.dart';
import '../bloc/checkout_bloc.dart';
import '../bloc/checkout_event.dart';
import '../bloc/checkout_state.dart';
import '../routing/checkout_routes.dart';

/// Checkout step 1 — shipping + payment method.
class CheckoutShippingPaymentScreen extends StatelessWidget {
  const CheckoutShippingPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shipping & payment')),
      body: BlocBuilder<CheckoutBloc, CheckoutState>(
        builder: (context, state) {
          if (state is! CheckoutReady && state is! CheckoutPlacing) {
            return const Center(child: AppLoadingIndicator());
          }
          final ready = state is CheckoutPlacing
              ? state.ready
              : state as CheckoutReady;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: AppStepperHeader(
                  steps: CheckoutRoutes.stepperLabels,
                  currentStep: 1,
                ),
              ),
              if (ready.stepError != null || ready.shippingError != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    ready.stepError ?? ready.shippingError!,
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
                      'Shipping method',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    for (final method in ready.shippingMethods)
                      ListTile(
                        selected: ready.session.shippingMethodId == method.id,
                        leading: Icon(
                          ready.session.shippingMethodId == method.id
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                        ),
                        title: Text(method.name),
                        subtitle: Text(
                          '${method.description} · ${method.etaLabel} · '
                          '${Formatters.currency(method.cost)}',
                        ),
                        onTap: () => context.read<CheckoutBloc>().add(
                          CheckoutShippingSelected(method.id),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      'Payment method',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    for (final method in ready.paymentMethods)
                      ListTile(
                        selected: ready.session.paymentMethodId == method.id,
                        leading: Icon(
                          ready.session.paymentMethodId == method.id
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                        ),
                        title: Text(method.displayLabel),
                        subtitle: method.type == CheckoutPaymentType.cod
                            ? const Text('Pay when your order arrives')
                            : null,
                        onTap: () => context.read<CheckoutBloc>().add(
                          CheckoutPaymentSelected(method.id),
                        ),
                      ),
                    if (ready.shippingCost != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Shipping cost: '
                        '${Formatters.currency(ready.shippingCost!)}',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                  ],
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: AppButton(
                    label: 'Continue',
                    isFullWidth: true,
                    onPressed: () {
                      final canContinue =
                          ready.session.hasShipping &&
                          ready.session.hasPayment &&
                          ready.shippingCost != null &&
                          ready.shippingError == null;
                      if (!canContinue) {
                        context.read<CheckoutBloc>().add(
                          const CheckoutContinueFromShippingPayment(),
                        );
                        return;
                      }
                      context.push(CheckoutRoutes.reviewPath);
                    },
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
