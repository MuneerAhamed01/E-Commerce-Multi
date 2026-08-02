import 'package:equatable/equatable.dart';

/// Every togglable feature in the platform, as a typed enum - never a raw
/// string - so a typo in a tenant's JSON can never silently create a new,
/// always-false flag. See docs/11_ENVIRONMENT_CONFIGURATION.md §7.
///
/// Flags are additive-only within a released version: removing one of
/// these entries outright (rather than defaulting it permanently on/off)
/// is a breaking change to every existing tenant's JSON and requires an
/// ADR - see docs/05_ARCHITECTURE_GUIDELINES.md §17.
enum FeatureFlag {
  wishlist,
  reviews,
  promotions,
  guestCheckout,
  notifications,
  support,
  multiplePaymentMethods,
  productVariants,
}

/// An immutable, per-tenant set of [FeatureFlag] values.
///
/// Backed by a typed `Map<FeatureFlag, bool>` (not raw strings) per
/// docs/11_ENVIRONMENT_CONFIGURATION.md §7. A flag absent from a tenant's
/// JSON defaults to enabled, so onboarding a new flag never requires every
/// existing client tenant file to be edited first (additive-only, per
/// docs/05_ARCHITECTURE_GUIDELINES.md §17).
final class FeatureFlagSet extends Equatable {
  const FeatureFlagSet(this._values);

  /// Every flag enabled - a safe default for local development or tests
  /// that don't care about flag gating.
  factory FeatureFlagSet.allEnabled() {
    return FeatureFlagSet({for (final flag in FeatureFlag.values) flag: true});
  }

  /// Parses a tenant JSON's `featureFlags` object (flag name -> `bool`).
  /// Unrecognized keys are ignored (forward-compatible with a JSON file
  /// authored against a newer flag set); missing keys default to enabled.
  factory FeatureFlagSet.fromJson(Map<String, dynamic> json) {
    return FeatureFlagSet({
      for (final flag in FeatureFlag.values)
        flag: json[flag.name] as bool? ?? true,
    });
  }

  final Map<FeatureFlag, bool> _values;

  /// Whether [flag] is enabled for this set. Defaults to enabled if [flag]
  /// isn't present at all (should not normally happen once constructed via
  /// [FeatureFlagSet.fromJson] or [FeatureFlagSet.allEnabled], both of
  /// which populate every known flag).
  bool isEnabled(FeatureFlag flag) => _values[flag] ?? true;

  /// Serializes back to the same shape [FeatureFlagSet.fromJson] reads.
  Map<String, dynamic> toJson() {
    return {for (final entry in _values.entries) entry.key.name: entry.value};
  }

  @override
  List<Object?> get props => [_values];
}

/// Single call-site for evaluating whether a feature is enabled, per
/// docs/11_ENVIRONMENT_CONFIGURATION.md §7: `FeatureFlagService.isEnabled(flag)`.
///
/// Every route registration and every nav-entry visibility check goes
/// through this exact method - never a direct `tenantConfig.featureFlags`
/// read - so there is one seam to extend later (e.g. a remote-config
/// override layered on top of tenant JSON) without touching call sites.
final class FeatureFlagService {
  // A private field can't be an initializing formal (`this._flags`) with a
  // public named parameter (`flags:`) at the same time - the explicit
  // assignment is intentional, not an oversight.
  // ignore: prefer_initializing_formals
  const FeatureFlagService({required FeatureFlagSet flags}) : _flags = flags;

  final FeatureFlagSet _flags;

  /// Whether [flag] is enabled for the tenant this service was built for.
  bool isEnabled(FeatureFlag flag) => _flags.isEnabled(flag);
}
