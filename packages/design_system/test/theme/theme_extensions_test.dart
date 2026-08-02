import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppSemanticColors', () {
    test(
      'lerp with a non-AppSemanticColors extension returns this unchanged',
      () {
        final colors = AppSemanticColors.light();
        final result = colors.lerp(null, 0.5);
        expect(result, same(colors));
      },
    );

    test(
      'lerp at t=0 returns the start colors and t=1 returns the end colors',
      () {
        final light = AppSemanticColors.light();
        final dark = AppSemanticColors.dark();

        final atStart = light.lerp(dark, 0);
        final atEnd = light.lerp(dark, 1);

        expect(atStart.border, light.border);
        expect(atEnd.border, dark.border);
      },
    );

    test('copyWith overrides only the provided fields', () {
      final light = AppSemanticColors.light();
      final copied = light.copyWith(border: AppColors.black);

      expect(copied.border, AppColors.black);
      expect(copied.success, light.success);
    });
  });

  group('AppSemanticColorsContext extension', () {
    testWidgets(
      'falls back to AppSemanticColors.light when the theme has no extension',
      (tester) async {
        late AppSemanticColors resolved;
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light(),
            home: Builder(
              builder: (context) {
                resolved = context.semanticColors;
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        expect(resolved.border, AppSemanticColors.light().border);
      },
    );

    testWidgets('resolves the registered extension when present', (
      tester,
    ) async {
      final theme = ThemeData.light().copyWith(
        extensions: [AppSemanticColors.dark()],
      );
      late AppSemanticColors resolved;
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Builder(
            builder: (context) {
              resolved = context.semanticColors;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(resolved.border, AppSemanticColors.dark().border);
    });
  });
}
