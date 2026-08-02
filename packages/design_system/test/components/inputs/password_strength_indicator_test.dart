import 'package:design_system/design_system.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils/pump_app.dart';

void main() {
  group('AppPasswordStrengthIndicator.strengthOf', () {
    test('empty password is weak', () {
      expect(
        AppPasswordStrengthIndicator.strengthOf(''),
        AppPasswordStrength.weak,
      );
    });

    test('short, single-case password is weak', () {
      expect(
        AppPasswordStrengthIndicator.strengthOf('abc'),
        AppPasswordStrength.weak,
      );
    });

    test('moderately varied password is fair', () {
      expect(
        AppPasswordStrengthIndicator.strengthOf('abcdefgh1'),
        AppPasswordStrength.fair,
      );
    });

    test('long password with mixed case, digits, and symbols is strong', () {
      expect(
        AppPasswordStrengthIndicator.strengthOf('Abcdefghij1!'),
        AppPasswordStrength.strong,
      );
    });
  });

  group('AppPasswordStrengthIndicator widget', () {
    testWidgets('exposes a semantic label describing the strength', (
      tester,
    ) async {
      await pumpApp(
        tester,
        const AppPasswordStrengthIndicator(password: 'Abcdefghij1!'),
      );

      expect(find.text('Strong'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.label == 'Password strength: Strong',
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows "Weak" for an empty password', (tester) async {
      await pumpApp(tester, const AppPasswordStrengthIndicator(password: ''));

      expect(find.text('Weak'), findsOneWidget);
    });
  });
}
