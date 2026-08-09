import 'package:authentication/authentication.dart';
import 'package:cart/cart.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wishlist/wishlist.dart';

import 'app_router.dart';

/// Root widget of the Storefront app.
///
/// Provides singleton [AuthBloc] + [WishlistCubit] + [CartBloc] and refreshes
/// [GoRouter] redirects when the session changes (Phase 7 / 12 / 13).
class AppWidget extends StatefulWidget {
  const AppWidget({
    required this.appConfig,
    required this.tenantConfig,
    super.key,
  });

  final AppConfig appConfig;
  final TenantConfig tenantConfig;

  @override
  State<AppWidget> createState() => _AppWidgetState();
}

class _AppWidgetState extends State<AppWidget> {
  late final AuthBloc _authBloc = getIt<AuthBloc>()..add(const AuthStarted());
  late final WishlistCubit _wishlistCubit = getIt<WishlistCubit>();
  late final CartBloc _cartBloc = getIt<CartBloc>();
  late final AuthSessionListenable _sessionListenable = AuthSessionListenable(
    _authBloc,
  );
  late final GoRouter _router = createStorefrontRouter(
    appConfig: widget.appConfig,
    tenantConfig: widget.tenantConfig,
    sessionOf: () => AuthSessionMapper.fromAuthState(_authBloc.state),
    refreshListenable: _sessionListenable,
  );

  @override
  void dispose() {
    _sessionListenable.dispose();
    // AuthBloc / WishlistCubit / CartBloc are DI lazySingletons — not disposed.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: _authBloc),
        BlocProvider<WishlistCubit>.value(value: _wishlistCubit),
        BlocProvider<CartBloc>.value(value: _cartBloc),
      ],
      child: MaterialApp.router(
        title: widget.tenantConfig.displayName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(widget.tenantConfig),
        darkTheme: AppTheme.dark(widget.tenantConfig),
        routerConfig: _router,
      ),
    );
  }
}
