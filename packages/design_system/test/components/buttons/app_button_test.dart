import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils/pump_app.dart';

void main() {
  testWidgets('invokes onPressed when tapped', (tester) async {
    var tapped = false;
    await pumpApp(
      tester,
      AppButton(label: 'Submit', onPressed: () => tapped = true),
    );

    await tester.tap(find.text('Submit'));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('renders as disabled and ignores taps when onPressed is null', (
    tester,
  ) async {
    await pumpApp(tester, const AppButton(label: 'Submit', onPressed: null));

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.enabled, isFalse);
  });

  testWidgets('shows a spinner instead of the label while isLoading', (
    tester,
  ) async {
    await pumpApp(
      tester,
      AppButton(label: 'Submit', onPressed: () {}, isLoading: true),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Submit'), findsNothing);
  });

  testWidgets('ignores taps while isLoading even with a non-null onPressed', (
    tester,
  ) async {
    var tapped = false;
    await pumpApp(
      tester,
      AppButton(
        label: 'Submit',
        onPressed: () => tapped = true,
        isLoading: true,
      ),
    );

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.enabled, isFalse);
    expect(tapped, isFalse);
  });

  testWidgets('renders an OutlinedButton for the outline variant', (
    tester,
  ) async {
    await pumpApp(
      tester,
      AppButton(
        label: 'Cancel',
        onPressed: () {},
        variant: AppButtonVariant.outline,
      ),
    );

    expect(find.byType(OutlinedButton), findsOneWidget);
  });

  testWidgets('renders a TextButton for the text variant', (tester) async {
    await pumpApp(
      tester,
      AppButton(
        label: 'Skip',
        onPressed: () {},
        variant: AppButtonVariant.text,
      ),
    );

    expect(find.byType(TextButton), findsOneWidget);
  });

  testWidgets('shows the leading icon when provided and not loading', (
    tester,
  ) async {
    await pumpApp(
      tester,
      AppButton(label: 'Add', onPressed: () {}, icon: Icons.add),
    );

    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('expands to fill available width when isFullWidth is true', (
    tester,
  ) async {
    await pumpApp(
      tester,
      AppButton(label: 'Continue', onPressed: () {}, isFullWidth: true),
    );

    final sizedBox = tester.widget<SizedBox>(
      find
          .ancestor(
            of: find.byType(ElevatedButton),
            matching: find.byType(SizedBox),
          )
          .first,
    );
    expect(sizedBox.width, double.infinity);
  });
}
