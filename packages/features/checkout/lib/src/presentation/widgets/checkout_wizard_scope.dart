import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/checkout_bloc.dart';
import '../bloc/checkout_event.dart';

/// Hosts a single [CheckoutBloc] for the address → review wizard steps.
class CheckoutWizardScope extends StatelessWidget {
  const CheckoutWizardScope({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CheckoutBloc>()..add(const CheckoutStarted()),
      child: child,
    );
  }
}
