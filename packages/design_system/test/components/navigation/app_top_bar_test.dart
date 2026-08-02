import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the given title', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(appBar: AppTopBar(title: 'Orders')),
      ),
    );

    expect(find.text('Orders'), findsOneWidget);
  });

  testWidgets(
    'withSearch variant embeds the given search bar instead of a title',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            appBar: AppTopBar(
              variant: AppTopBarVariant.withSearch,
              searchBar: AppSearchBar(),
            ),
          ),
        ),
      );

      expect(find.byType(AppSearchBar), findsOneWidget);
    },
  );

  test('asserts a searchBar is required for the withSearch variant', () {
    expect(
      () => AppTopBar(variant: AppTopBarVariant.withSearch),
      throwsAssertionError,
    );
  });

  testWidgets('transparentScroll variant is transparent until scrolled', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          appBar: AppTopBar(variant: AppTopBarVariant.transparentScroll),
        ),
      ),
    );

    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    expect(appBar.backgroundColor, Colors.transparent);
  });

  testWidgets('reports its preferred size as the standard toolbar height', (
    tester,
  ) async {
    const topBar = AppTopBar(title: 'Orders');
    expect(topBar.preferredSize, const Size.fromHeight(kToolbarHeight));
  });
}
