import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('semantic colors are fully opaque', () {
    for (final color in [
      AppColors.success,
      AppColors.warning,
      AppColors.info,
      AppColors.error,
    ]) {
      expect(color.a, 1.0);
    }
  });

  test('neutral scale gets darker as the suffix number increases', () {
    expect(
      AppColors.neutral50.computeLuminance(),
      greaterThan(AppColors.neutral500.computeLuminance()),
    );
    expect(
      AppColors.neutral500.computeLuminance(),
      greaterThan(AppColors.neutral900.computeLuminance()),
    );
  });

  test('white and black are the expected extremes', () {
    expect(AppColors.white.computeLuminance(), 1.0);
    expect(AppColors.black.computeLuminance(), 0.0);
  });
}
