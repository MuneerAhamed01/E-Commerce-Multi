import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/cart_bloc.dart';
import '../bloc/cart_state.dart';
import '../routing/cart_routes.dart';

/// Shell-level cart icon with live quantity badge.
class CartBadge extends StatelessWidget {
  const CartBadge({super.key, this.onPressed});

  /// Defaults to navigating to [CartRoutes.path].
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      buildWhen: (prev, next) => prev.itemCount != next.itemCount,
      builder: (context, state) {
        final count = state.itemCount;
        final icon = AppIconButton(
          icon: Icons.shopping_cart_outlined,
          tooltip: 'Cart',
          onPressed: onPressed ?? () => context.push(CartRoutes.path),
        );
        if (count <= 0) {
          return icon;
        }
        return Badge(label: Text(count > 99 ? '99+' : '$count'), child: icon);
      },
    );
  }
}
