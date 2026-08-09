import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/checkout_bloc.dart';
import '../bloc/checkout_event.dart';
import '../bloc/checkout_state.dart';
import '../routing/checkout_routes.dart';

/// Checkout step 0 — select or add a shipping address.
class CheckoutAddressScreen extends StatelessWidget {
  const CheckoutAddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: BlocConsumer<CheckoutBloc, CheckoutState>(
        listenWhen: (prev, next) =>
            next is CheckoutPlaced && prev is! CheckoutPlaced,
        listener: (context, state) {
          if (state is CheckoutPlaced) {
            context.go(CheckoutRoutes.confirmationPath(state.orderId));
          }
        },
        builder: (context, state) {
          return switch (state) {
            CheckoutLoading() || CheckoutPlacing() => const Center(
              child: AppLoadingIndicator(message: 'Loading checkout…'),
            ),
            CheckoutError(:final message) => AppErrorState(
              title: 'Checkout unavailable',
              message: message,
              onRetry: () =>
                  context.read<CheckoutBloc>().add(const CheckoutRetried()),
            ),
            CheckoutPlaced() => const Center(child: AppLoadingIndicator()),
            CheckoutReady() => _AddressBody(ready: state),
          };
        },
      ),
    );
  }
}

class _AddressBody extends StatefulWidget {
  const _AddressBody({required this.ready});

  final CheckoutReady ready;

  @override
  State<_AddressBody> createState() => _AddressBodyState();
}

class _AddressBodyState extends State<_AddressBody> {
  bool _showForm = false;
  final _label = TextEditingController();
  final _line1 = TextEditingController();
  final _line2 = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _postal = TextEditingController();

  @override
  void dispose() {
    _label.dispose();
    _line1.dispose();
    _line2.dispose();
    _city.dispose();
    _state.dispose();
    _postal.dispose();
    super.dispose();
  }

  void _submitForm() {
    final address = Address(
      line1: _line1.text.trim(),
      line2: _line2.text.trim().isEmpty ? null : _line2.text.trim(),
      city: _city.text.trim(),
      state: _state.text.trim(),
      postalCode: _postal.text.trim(),
      countryCode: 'US',
      label: _label.text.trim().isEmpty ? null : _label.text.trim(),
    );
    context.read<CheckoutBloc>().add(CheckoutAddressSaved(address));
    setState(() => _showForm = false);
    _label.clear();
    _line1.clear();
    _line2.clear();
    _city.clear();
    _state.clear();
    _postal.clear();
  }

  @override
  Widget build(BuildContext context) {
    final ready = widget.ready;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: AppStepperHeader(
            steps: CheckoutRoutes.stepperLabels,
            currentStep: 0,
          ),
        ),
        if (ready.stepError != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              ready.stepError!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Shipping address',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              if (ready.addresses.isEmpty && !_showForm)
                const AppEmptyState(
                  title: 'No saved addresses',
                  message: 'Add an address to continue.',
                ),
              for (final saved in ready.addresses) ...[
                AppAddressCard(
                  address: saved.address,
                  variant: AppAddressCardVariant.selectable,
                  isDefault: saved.isDefault,
                  isSelected: ready.session.selectedAddressId == saved.id,
                  onSelect: () => context.read<CheckoutBloc>().add(
                    CheckoutAddressSelected(saved.id),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (_showForm) ...[
                AppTextField(controller: _label, label: 'Label (optional)'),
                const SizedBox(height: 8),
                AppTextField(controller: _line1, label: 'Address line 1'),
                const SizedBox(height: 8),
                AppTextField(controller: _line2, label: 'Address line 2'),
                const SizedBox(height: 8),
                AppTextField(controller: _city, label: 'City'),
                const SizedBox(height: 8),
                AppTextField(controller: _state, label: 'State'),
                const SizedBox(height: 8),
                AppTextField(
                  controller: _postal,
                  label: 'Postal code',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                AppButton(
                  label: 'Save address',
                  onPressed: _submitForm,
                  isFullWidth: true,
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => setState(() => _showForm = false),
                  child: const Text('Cancel'),
                ),
              ] else
                TextButton.icon(
                  onPressed: () => setState(() => _showForm = true),
                  icon: const Icon(Icons.add),
                  label: const Text('Add address'),
                ),
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
                if (!ready.session.hasAddress) {
                  context.read<CheckoutBloc>().add(
                    const CheckoutContinueFromAddress(),
                  );
                  return;
                }
                context.push(CheckoutRoutes.shippingPaymentPath);
              },
            ),
          ),
        ),
      ],
    );
  }
}
