import 'package:authentication/authentication.dart';
import 'package:checkout/checkout.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Navigates to checkout address, or login with return-to when guest.
void navigateToCheckout(BuildContext context) {
  final auth = context.read<AuthBloc>().state;
  if (auth is! AuthAuthenticated) {
    final redirect = Uri.encodeComponent(CheckoutRoutes.addressPath);
    context.push(
      '${AuthRoutes.loginPath}?${SystemRoutes.redirectQueryKey}=$redirect',
    );
    return;
  }
  context.push(CheckoutRoutes.addressPath);
}
