import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('resolves to true when the confirm action is tapped', (
    tester,
  ) async {
    bool? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await AppAlertDialog.show(
                context,
                title: 'Delete address?',
                message: "This can't be undone.",
                confirmLabel: 'Delete',
              );
            },
            child: const Text('Open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Delete address?'), findsOneWidget);
    expect(find.text("This can't be undone."), findsOneWidget);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(result, isTrue);
  });

  testWidgets('resolves to false when cancel is tapped', (tester) async {
    bool? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await AppAlertDialog.show(
                context,
                title: 'Log out?',
                message: 'You will need to sign in again.',
              );
            },
            child: const Text('Open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(result, isFalse);
  });

  testWidgets('renders the confirm button as destructive for that variant', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AppAlertDialog(
          title: 'Delete?',
          message: 'Cannot be undone',
          confirmLabel: 'Delete',
          variant: AppAlertDialogVariant.destructive,
        ),
      ),
    );

    final buttons = tester.widgetList<AppButton>(find.byType(AppButton));
    final confirmButton = buttons.firstWhere((b) => b.label == 'Delete');
    expect(confirmButton.variant, AppButtonVariant.destructive);
  });
}
