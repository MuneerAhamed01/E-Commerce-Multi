import 'package:equatable/equatable.dart';

import 'feature_flags.dart';

/// A tenant's visual identity: colors, logo, and typography references.
///
/// Colors are stored as `#RRGGBB`/`#AARRGGBB` hex strings rather than a
/// Flutter `Color` - `core` has zero Flutter dependency (see
/// docs/02_PROJECT_STRUCTURE.md §4), so parsing a hex string into a `Color`
/// is `design_system`'s job (`app_theme.dart`, added in Phase 4), keeping
/// this a plain, JSON-round-trippable value object.
final class BrandingTokens extends Equatable {
  const BrandingTokens({
    required this.primaryColorHex,
    required this.secondaryColorHex,
    required this.logoAssetPath,
    this.logoUrl,
    this.fontFamily = 'Inter',
  });

  factory BrandingTokens.fromJson(Map<String, dynamic> json) {
    return BrandingTokens(
      primaryColorHex: json['primaryColorHex'] as String,
      secondaryColorHex: json['secondaryColorHex'] as String,
      logoAssetPath: json['logoAssetPath'] as String,
      logoUrl: json['logoUrl'] as String?,
      fontFamily: json['fontFamily'] as String? ?? 'Inter',
    );
  }

  /// `#RRGGBB` hex string for the tenant's primary brand color.
  final String primaryColorHex;

  /// `#RRGGBB` hex string for the tenant's secondary/accent brand color.
  final String secondaryColorHex;

  /// Bundled-asset path to this tenant's logo, used when [logoUrl] is
  /// absent (Phase 1 default; a remote logo becomes the common case once
  /// the Tenant Management admin screen can upload one).
  final String logoAssetPath;

  /// Remote logo URL, when the tenant has uploaded a custom one. `null`
  /// falls back to [logoAssetPath].
  final String? logoUrl;

  /// Font family reference, resolved against fonts registered in
  /// `design_system`'s theme (Phase 4).
  final String fontFamily;

  Map<String, dynamic> toJson() {
    return {
      'primaryColorHex': primaryColorHex,
      'secondaryColorHex': secondaryColorHex,
      'logoAssetPath': logoAssetPath,
      if (logoUrl != null) 'logoUrl': logoUrl,
      'fontFamily': fontFamily,
    };
  }

  @override
  List<Object?> get props => [
    primaryColorHex,
    secondaryColorHex,
    logoAssetPath,
    logoUrl,
    fontFamily,
  ];
}

/// A tenant's copy-string overrides: a flat key -> localized string map,
/// consulted by presentation-layer copy (e.g. `FailureMessageMapper`,
/// added when the first feature needs it) before falling back to the
/// platform default string. See docs/05_ARCHITECTURE_GUIDELINES.md §13.
final class CopyOverrides extends Equatable {
  const CopyOverrides(this._values);

  /// No overrides - every lookup falls back to the caller-supplied default.
  const CopyOverrides.empty() : _values = const {};

  factory CopyOverrides.fromJson(Map<String, dynamic> json) {
    return CopyOverrides(
      json.map((key, value) => MapEntry(key, value as String)),
    );
  }

  final Map<String, String> _values;

  /// Returns the tenant's override for [key], or [fallback] when this
  /// tenant hasn't overridden it.
  String resolve(String key, String fallback) => _values[key] ?? fallback;

  Map<String, String> toJson() => _values;

  @override
  List<Object?> get props => [_values];
}

/// A tenant's full configuration: branding, copy, feature flags, locale,
/// and guest-access policy. Loaded once at bootstrap from
/// `config/tenants/<tenantId>_tenant.json` in this plan's scope (Phase 1:
/// bundled asset; future: Firestore-backed, behind the same shape - see
/// docs/11_ENVIRONMENT_CONFIGURATION.md §6 and docs/10_DATA_FLOW.md §7).
final class TenantConfig extends Equatable {
  const TenantConfig({
    required this.tenantId,
    required this.displayName,
    required this.branding,
    required this.copy,
    required this.featureFlags,
    required this.defaultLocale,
    required this.supportEmail,
    required this.allowGuestBrowsing,
    required this.allowGuestCart,
  });

  factory TenantConfig.fromJson(Map<String, dynamic> json) {
    return TenantConfig(
      tenantId: json['tenantId'] as String,
      displayName: json['displayName'] as String,
      branding: BrandingTokens.fromJson(
        json['branding'] as Map<String, dynamic>,
      ),
      copy: json['copy'] == null
          ? const CopyOverrides.empty()
          : CopyOverrides.fromJson(json['copy'] as Map<String, dynamic>),
      featureFlags: json['featureFlags'] == null
          ? FeatureFlagSet.allEnabled()
          : FeatureFlagSet.fromJson(
              json['featureFlags'] as Map<String, dynamic>,
            ),
      defaultLocale: json['defaultLocale'] as String? ?? 'en_US',
      supportEmail: json['supportEmail'] as String,
      allowGuestBrowsing: json['allowGuestBrowsing'] as bool? ?? true,
      allowGuestCart: json['allowGuestCart'] as bool? ?? true,
    );
  }

  /// Stable tenant identifier - also the `<tenantId>` in this tenant's
  /// `<tenantId>_tenant.json` file name.
  final String tenantId;

  /// Human-readable name shown in app titles, emails, and admin UI.
  final String displayName;

  final BrandingTokens branding;

  final CopyOverrides copy;

  final FeatureFlagSet featureFlags;

  /// BCP-47-ish locale identifier (`'en_US'`) used for default
  /// formatting/copy when no user preference overrides it.
  final String defaultLocale;

  final String supportEmail;

  /// Whether an unauthenticated visitor can browse the storefront catalog.
  final bool allowGuestBrowsing;

  /// Whether an unauthenticated visitor can add items to a cart (checkout
  /// itself may still require sign-in - see `guestCheckout` in
  /// [FeatureFlag]).
  final bool allowGuestCart;

  Map<String, dynamic> toJson() {
    return {
      'tenantId': tenantId,
      'displayName': displayName,
      'branding': branding.toJson(),
      'copy': copy.toJson(),
      'featureFlags': featureFlags.toJson(),
      'defaultLocale': defaultLocale,
      'supportEmail': supportEmail,
      'allowGuestBrowsing': allowGuestBrowsing,
      'allowGuestCart': allowGuestCart,
    };
  }

  @override
  List<Object?> get props => [
    tenantId,
    displayName,
    branding,
    copy,
    featureFlags,
    defaultLocale,
    supportEmail,
    allowGuestBrowsing,
    allowGuestCart,
  ];
}
