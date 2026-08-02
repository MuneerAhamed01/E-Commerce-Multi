import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const locales = [
    AppLocaleOption(code: 'en_US', label: 'English (US)'),
    AppLocaleOption(code: 'fr_FR', label: 'Français'),
  ];

  testWidgets('shows every locale label', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => AppLanguagePickerSheet.show(
              context,
              locales: locales,
              selected: 'en_US',
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('English (US)'), findsOneWidget);
    expect(find.text('Français'), findsOneWidget);
  });

  testWidgets('resolves to the tapped locale code', (tester) async {
    String? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await AppLanguagePickerSheet.show(
                context,
                locales: locales,
                selected: 'en_US',
              );
            },
            child: const Text('Open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Français'));
    await tester.pumpAndSettle();

    expect(result, 'fr_FR');
  });
}
