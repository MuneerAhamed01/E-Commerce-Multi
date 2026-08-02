import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('display styles are larger than headline styles', () {
    expect(
      AppTypography.displayLarge.fontSize,
      greaterThan(AppTypography.headlineLarge.fontSize!),
    );
    expect(
      AppTypography.headlineLarge.fontSize,
      greaterThan(AppTypography.titleLarge.fontSize!),
    );
  });

  test('body styles use the regular weight', () {
    expect(AppTypography.bodyLarge.fontWeight, AppTypography.regular);
    expect(AppTypography.bodyMedium.fontWeight, AppTypography.regular);
    expect(AppTypography.bodySmall.fontWeight, AppTypography.regular);
  });

  test(
    'label styles carry positive letter spacing for legibility at small sizes',
    () {
      expect(AppTypography.labelLarge.letterSpacing, greaterThan(0));
      expect(AppTypography.labelMedium.letterSpacing, greaterThan(0));
      expect(AppTypography.labelSmall.letterSpacing, greaterThan(0));
    },
  );

  test('none of the base styles hardcode a color', () {
    final styles = [
      AppTypography.displayLarge,
      AppTypography.displayMedium,
      AppTypography.displaySmall,
      AppTypography.headlineLarge,
      AppTypography.headlineMedium,
      AppTypography.headlineSmall,
      AppTypography.titleLarge,
      AppTypography.titleMedium,
      AppTypography.titleSmall,
      AppTypography.bodyLarge,
      AppTypography.bodyMedium,
      AppTypography.bodySmall,
      AppTypography.labelLarge,
      AppTypography.labelMedium,
      AppTypography.labelSmall,
    ];

    for (final style in styles) {
      expect(style.color, isNull);
    }
  });
}
