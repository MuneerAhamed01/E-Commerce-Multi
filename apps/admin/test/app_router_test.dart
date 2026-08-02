import 'package:admin/app/app_router.dart';
import 'package:authentication/authentication.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

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

void main() {
  late RouterTestAuth auth;

  setUp(() async {
    auth = await RouterTestAuth.create(displayName: 'Test Admin');
  });

  tearDown(() async {
    await auth.dispose();
  });

  testWidgets('splash resolves guest to admin login', (tester) async {
    final router = createAdminRouter(
      appConfig: auth.config,
      tenantConfig: auth.tenant,
      sessionOf: auth.sessionOf,
      refreshListenable: auth.listenable,
    );

    await tester.pumpWidget(
      BlocProvider<AuthBloc>.value(
        value: auth.bloc,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await _pumpUntil(
      tester,
      () => router.state.matchedLocation == SystemRoutes.adminLoginPath,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(router.state.matchedLocation, SystemRoutes.adminLoginPath);
    expect(find.text('Admin sign in'), findsOneWidget);
  });

  testWidgets('dashboard redirects guests to login', (tester) async {
    final router = createAdminRouter(
      appConfig: auth.config,
      tenantConfig: auth.tenant,
      sessionOf: auth.sessionOf,
      refreshListenable: auth.listenable,
    );

    await tester.pumpWidget(
      BlocProvider<AuthBloc>.value(
        value: auth.bloc,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await _pumpUntil(
      tester,
      () => router.state.matchedLocation == SystemRoutes.adminLoginPath,
    );

    router.go(SystemRoutes.adminDashboardPath);
    await _pumpUntil(
      tester,
      () => router.state.uri.toString().contains(SystemRoutes.adminLoginPath),
    );

    expect(router.state.matchedLocation, SystemRoutes.adminLoginPath);
  });

  testWidgets('unknown admin path shows 404', (tester) async {
    final router = createAdminRouter(
      appConfig: auth.config,
      tenantConfig: auth.tenant,
      sessionOf: auth.sessionOf,
      refreshListenable: auth.listenable,
    );

    await tester.pumpWidget(
      BlocProvider<AuthBloc>.value(
        value: auth.bloc,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await _pumpUntil(
      tester,
      () => router.state.matchedLocation == SystemRoutes.adminLoginPath,
    );

    router.go('/admin/nope');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Page not found'), findsOneWidget);
  });
}
