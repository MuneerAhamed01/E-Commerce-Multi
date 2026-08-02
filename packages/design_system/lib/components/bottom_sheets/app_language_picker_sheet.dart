import 'package:flutter/material.dart';

/// A single selectable locale within an [AppLanguagePickerSheet].
class AppLocaleOption {
  const AppLocaleOption({required this.code, required this.label});

  /// BCP-47-ish locale identifier, matching `TenantConfig.defaultLocale`'s
  /// format (e.g. `'en_US'`) - see
  /// `packages/core/lib/config/tenant_config.dart`.
  final String code;

  final String label;
}

/// A locale-selection sheet, per docs/08_COMPONENT_LIBRARY.md §4
/// (`LanguagePickerSheet`). Used in Settings.
///
/// ```dart
/// AppLanguagePickerSheet.show(
///   context,
///   locales: const [
///     AppLocaleOption(code: 'en_US', label: 'English (US)'),
///     AppLocaleOption(code: 'fr_FR', label: 'Français'),
///   ],
///   selected: 'en_US',
/// ).then((code) { if (code != null) bloc.add(LocaleChanged(code)); });
/// ```
class AppLanguagePickerSheet extends StatelessWidget {
  const AppLanguagePickerSheet({
    required this.locales,
    required this.selected,
    super.key,
  });

  final List<AppLocaleOption> locales;
  final String selected;

  static Future<String?> show(
    BuildContext context, {
    required List<AppLocaleOption> locales,
    required String selected,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      builder: (_) =>
          AppLanguagePickerSheet(locales: locales, selected: selected),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RadioGroup<String>(
        groupValue: selected,
        onChanged: (code) => Navigator.of(context).pop(code),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final locale in locales)
              RadioListTile<String>(
                value: locale.code,
                title: Text(locale.label),
              ),
          ],
        ),
      ),
    );
  }
}
