/// Shared, tenant-neutral form validators.
///
/// Each returns `null` when [value] is valid, or a user-facing error
/// message otherwise - the exact shape Flutter's `TextFormField.validator`
/// expects, so these can be passed directly as a validator callback from
/// any feature's presentation layer without adapting the return type.
///
/// These are intentionally generic (not tenant-copy-overridable) - a
/// feature that needs tenant-specific validation copy wraps one of these
/// and swaps in `TenantConfig.copyOverrides` at the call site.
abstract final class Validators {
  static final RegExp _emailPattern = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');

  static final RegExp _phonePattern = RegExp(r'^\+?[0-9]{7,15}$');

  static final RegExp _letterPattern = RegExp('[A-Za-z]');

  static final RegExp _digitPattern = RegExp('[0-9]');

  /// Validates that [value] is a plausible email address.
  static String? email(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Email is required';
    }
    if (!_emailPattern.hasMatch(trimmed)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  /// Validates that [value] is a plausible phone number (7-15 digits,
  /// optional leading `+`, ignoring spaces/hyphens/parentheses).
  static String? phone(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Phone number is required';
    }
    final normalized = trimmed.replaceAll(RegExp(r'[\s()-]'), '');
    if (!_phonePattern.hasMatch(normalized)) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  /// Validates that [value] meets a minimum password strength bar: at
  /// least 8 characters, containing at least one letter and one digit.
  static String? passwordStrength(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!_letterPattern.hasMatch(value) || !_digitPattern.hasMatch(value)) {
      return 'Password must contain both letters and numbers';
    }
    return null;
  }

  /// Validates that [value] is non-empty, for generic required fields.
  /// [fieldName] is interpolated into the message (e.g. `'First name'`).
  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
}
