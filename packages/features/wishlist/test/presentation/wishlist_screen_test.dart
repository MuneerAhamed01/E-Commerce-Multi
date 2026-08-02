import 'package:authentication/authentication.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:products/products.dart';
import 'package:wishlist/wishlist.dart';

import '../helpers/wishlist_test_harness.dart';

void main() {
  late WishlistTestHarness harness;
  WishlistCubit? cubit;

  setUp(() async {
    harness = await WishlistTestHarness.create();
  });

  tearDown(() async {
    await cubit?.close();
    cubit = null;
    await harness.dispose();
  });

  testWidgets('empty wishlist shows Browse Products CTA', (tester) async {
    await tester.runAsync(() async {
      await harness.loginAs(
        email: 'mia.garcia03@example.com',
        password: AuthDemoCredentials.mockPassword,
      );
      cubit = harness.createCubit();
      await _waitForLoaded(cubit!);
    });
    expect((cubit!.state as WishlistLoaded).items, isEmpty);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: harness.authBloc),
          BlocProvider<WishlistCubit>.value(value: cubit!),
        ],
        child: const MaterialApp(home: WishlistScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Your wishlist is empty'), findsOneWidget);
    expect(find.text('Browse Products'), findsOneWidget);
  });

  testWidgets('seeded wishlist shows product cards', (tester) async {
    await tester.runAsync(() async {
      await harness.loginAsDemoCustomer();
      cubit = harness.createCubit();
      await _waitForLoaded(cubit!);
    });
    expect((cubit!.state as WishlistLoaded).items, isNotEmpty);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: harness.authBloc),
          BlocProvider<WishlistCubit>.value(value: cubit!),
        ],
        child: const MaterialApp(home: WishlistScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(ProductCard), findsNWidgets(3));
    expect(find.text('Your wishlist is empty'), findsNothing);
  });
}

Future<void> _waitForLoaded(WishlistCubit cubit) async {
  if (cubit.state is WishlistLoaded) {
    return;
  }
  await cubit.stream
      .firstWhere((s) => s is WishlistLoaded)
      .timeout(const Duration(seconds: 3));
}
