import 'package:design_system/design_system.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('radius scale is strictly increasing up to full', () {
    const values = [
      AppRadii.none,
      AppRadii.xs,
      AppRadii.sm,
      AppRadii.md,
      AppRadii.lg,
      AppRadii.xl,
    ];

    for (var i = 1; i < values.length; i++) {
      expect(values[i], greaterThan(values[i - 1]));
    }
    expect(AppRadii.full, greaterThan(AppRadii.xl));
  });

  test('borderRadius convenience getters match their scalar counterparts', () {
    expect(
      AppRadii.borderRadiusMd,
      const BorderRadius.all(Radius.circular(AppRadii.md)),
    );
    expect(
      AppRadii.borderRadiusFull,
      const BorderRadius.all(Radius.circular(AppRadii.full)),
    );
  });
}
