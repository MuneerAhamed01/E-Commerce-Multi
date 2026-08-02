import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the message via the ScaffoldMessenger', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () =>
                  AppSnackbar.show(context, message: 'Added to cart'),
              child: const Text('Add'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Add'));
    await tester.pump();

    expect(find.text('Added to cart'), findsOneWidget);
  });

  testWidgets('shows an action button that invokes onAction when tapped', (
    tester,
  ) async {
    var undone = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => AppSnackbar.show(
                context,
                message: 'Item removed',
                actionLabel: 'Undo',
                onAction: () => undone = true,
              ),
              child: const Text('Remove'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Undo'));
    expect(undone, isTrue);
  });

  testWidgets('renders distinct icons per variant', (tester) async {
    Future<void> showAndVerify(
      AppSnackbarVariant variant,
      IconData expectedIcon,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => AppSnackbar.show(
                  context,
                  message: 'Message',
                  variant: variant,
                ),
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();
      expect(find.byIcon(expectedIcon), findsOneWidget);
    }

    await showAndVerify(AppSnackbarVariant.success, Icons.check_circle_outline);
    await showAndVerify(AppSnackbarVariant.error, Icons.error_outline);
  });
}
