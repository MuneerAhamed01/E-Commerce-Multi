import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows every action label and icon', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => AppActionSheet.show(
              context,
              actions: [
                AppActionSheetAction(
                  label: 'Reorder',
                  icon: Icons.replay,
                  onTap: () {},
                ),
                AppActionSheetAction(
                  label: 'Remove',
                  icon: Icons.delete_outline,
                  isDestructive: true,
                  onTap: () {},
                ),
              ],
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Reorder'), findsOneWidget);
    expect(find.text('Remove'), findsOneWidget);
    expect(find.byIcon(Icons.replay), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);
  });

  testWidgets(
    'dismisses the sheet and invokes onTap when an action is tapped',
    (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => AppActionSheet.show(
                context,
                actions: [
                  AppActionSheetAction(
                    label: 'Reorder',
                    onTap: () => tapped = true,
                  ),
                ],
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reorder'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
      expect(find.text('Reorder'), findsNothing);
    },
  );
}
