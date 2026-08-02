import 'package:authentication/authentication.dart';
import 'package:cart/cart.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:storefront/app/app_router.dart';
import 'package:wishlist/wishlist.dart';

import 'helpers/router_test_auth.dart';

Future<void> _pumpUntil(
  WidgetTester tester,
  bool Function() condition, {
  int maxPumps = 60,
}) async {
  for (var i = 0; i < maxPumps; i++) {
    await tester.pump(const Duration(milliseconds: 50));
    if (condition()) {
      return;
    }
  }
  fail('Condition not met after $maxPumps pumps');
}

Widget _app(GoRouter router, RouterTestAuth auth) {
  return MultiBlocProvider(
    providers: [
      BlocProvider<AuthBloc>.value(value: auth.bloc),
      BlocProvider<WishlistCubit>.value(value: getIt<WishlistCubit>()),
      BlocProvider<CartBloc>.value(value: getIt<CartBloc>()),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  late RouterTestAuth auth;

  setUp(() async {
    auth = await RouterTestAuth.create();
  });

  tearDown(() async {
    await auth.dispose();
  });

  testWidgets('splash resolves guest with onboarding seen to login', (
    tester,
  ) async {
    await auth.setOnboardingSeen();
    final router = createStorefrontRouter(
      appConfig: auth.config,
      tenantConfig: auth.tenant,
      sessionOf: auth.sessionOf,
      refreshListenable: auth.listenable,
    );

    await tester.pumpWidget(_app(router, auth));
    await _pumpUntil(
      tester,
      () => router.state.matchedLocation == SystemRoutes.storefrontLoginPath,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(router.state.matchedLocation, SystemRoutes.storefrontLoginPath);
    expect(find.textContaining('Welcome back'), findsOneWidget);
  });

  testWidgets('unknown path shows 404 with go-home CTA', (tester) async {
    await auth.setOnboardingSeen();
    final router = createStorefrontRouter(
      appConfig: auth.config,
      tenantConfig: auth.tenant,
      sessionOf: auth.sessionOf,
      refreshListenable: auth.listenable,
    );

    await tester.pumpWidget(_app(router, auth));
    await _pumpUntil(
      tester,
      () => router.state.matchedLocation == SystemRoutes.storefrontLoginPath,
    );

    router.go('/this-route-does-not-exist');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Page not found'), findsOneWidget);
    expect(find.text('Go home'), findsOneWidget);
  });

  testWidgets('wishlist redirects guests to login', (tester) async {
    await auth.setOnboardingSeen();
    final router = createStorefrontRouter(
      appConfig: auth.config,
      tenantConfig: auth.tenant,
      sessionOf: auth.sessionOf,
      refreshListenable: auth.listenable,
    );

    await tester.pumpWidget(_app(router, auth));
    await _pumpUntil(
      tester,
      () => router.state.matchedLocation == SystemRoutes.storefrontLoginPath,
    );

    router.go('/wishlist');
    await _pumpUntil(
      tester,
      () => router.state.uri.toString().contains(
        SystemRoutes.storefrontLoginPath,
      ),
    );

    expect(router.state.matchedLocation, SystemRoutes.storefrontLoginPath);
  });
}
