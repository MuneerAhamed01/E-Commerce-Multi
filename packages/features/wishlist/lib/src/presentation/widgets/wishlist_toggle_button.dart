import 'package:authentication/authentication.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../cubit/wishlist_cubit.dart';
import '../cubit/wishlist_state.dart';
import '../routing/wishlist_routes.dart';

/// Heart-icon wishlist toggle synced via the app-wide [WishlistCubit].
class WishlistToggleButton extends StatelessWidget {
  const WishlistToggleButton({
    required this.productId,
    this.variantId,
    this.returnToPath,
    super.key,
  });

  final String productId;
  final String? variantId;

  /// Override return-to path after login (defaults to current URI, else
  /// [WishlistRoutes.path]).
  final String? returnToPath;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WishlistCubit, WishlistState>(
      buildWhen: (prev, next) {
        final prevIn = prev is WishlistLoaded && prev.contains(productId);
        final nextIn = next is WishlistLoaded && next.contains(productId);
        final prevBusy = prev is WishlistLoaded && prev.isToggling;
        final nextBusy = next is WishlistLoaded && next.isToggling;
        return prevIn != nextIn || prevBusy != nextBusy;
      },
      builder: (context, state) {
        final isWishlisted =
            state is WishlistLoaded && state.contains(productId);
        final isBusy = state is WishlistLoaded && state.isToggling;

        return AppIconButton(
          icon: isWishlisted ? Icons.favorite : Icons.favorite_border,
          tooltip: isWishlisted ? 'Remove from wishlist' : 'Add to wishlist',
          onPressed: isBusy
              ? null
              : () => _onPressed(context, isWishlisted: isWishlisted),
        );
      },
    );
  }

  void _onPressed(BuildContext context, {required bool isWishlisted}) {
    final authState = context.read<AuthBloc>().state;
    final cubit = context.read<WishlistCubit>();

    if (authState is! AuthAuthenticated) {
      cubit.queueToggle(productId: productId, variantId: variantId);
      final redirectTarget =
          returnToPath ??
          GoRouterState.of(context).uri.toString().ifEmpty(WishlistRoutes.path);
      final redirect = Uri.encodeComponent(redirectTarget);
      context.push(
        '${AuthRoutes.loginPath}?${SystemRoutes.redirectQueryKey}=$redirect',
      );
      return;
    }

    cubit.toggle(productId: productId, variantId: variantId);
  }
}

extension on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}
