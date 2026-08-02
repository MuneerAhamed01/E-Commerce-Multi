import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('spacing scale is strictly increasing', () {
    const values = [
      AppSpacing.xxs,
      AppSpacing.xs,
      AppSpacing.sm,
      AppSpacing.smMd,
      AppSpacing.md,
      AppSpacing.lg,
      AppSpacing.xl,
      AppSpacing.xxl,
      AppSpacing.xxxl,
    ];

    for (var i = 1; i < values.length; i++) {
      expect(
        values[i],
        greaterThan(values[i - 1]),
        reason: 'index $i should be greater than index ${i - 1}',
      );
    }
  });

  test('baseline unit matches documented value', () {
    expect(AppSpacing.md, 16);
  });
}
