import 'package:equatable/equatable.dart';

import '../logging/app_logger.dart';

/// Which deployment stage the running build targets.
///
/// Selecting a flavor at the Flutter level (`main_dev.dart` vs
/// `main_staging.dart` vs `main_prod.dart`) is what actually determines
/// this - it is passed in by the flavor entry point, never read back out of
/// an environment variable, so there is exactly one source of truth for
/// "which flavor is this build". See docs/11_ENVIRONMENT_CONFIGURATION.md §2.
enum Environment {
  dev,
  staging,
  prod;

  bool get isProduction => this == Environment.prod;
}

/// Which backing data source repositories should bind to at DI-registration
/// time. Every environment defaults to [mock] throughout this plan's scope
/// - see docs/05_ARCHITECTURE_GUIDELINES.md §16.
enum DataSourceMode { mock, firebase }

/// Immutable, environment-level configuration, constructed once at
/// bootstrap and never mutated. This is the *only* place
/// `String.fromEnvironment`/`bool.fromEnvironment`/`int.fromEnvironment`
/// are called anywhere in the platform - every other layer (including
/// every feature) depends on this object instead of reading a `--dart-define`
/// value directly. See docs/11_ENVIRONMENT_CONFIGURATION.md §3 and §5.
final class AppConfig extends Equatable {
  const AppConfig({
    required this.environment,
    required this.dataSourceMode,
    required this.logLevel,
    required this.mockLatencyMin,
    required this.mockLatencyMax,
    required this.isDeveloperModeAvailable,
    this.storefrontMaintenanceMode = false,
    this.adminMaintenanceMode = false,
  });

  /// Builds the [AppConfig] for [environment], applying `--dart-define`
  /// overrides on top of that environment's documented defaults (see
  /// docs/11_ENVIRONMENT_CONFIGURATION.md §1 and §3).
  ///
  /// [developerModeForcedOff] is a defense-in-depth switch: `main_prod.dart`
  /// passes `true` as a *hardcoded source-level literal* (not itself sourced
  /// from an environment variable) so a misconfigured `ENABLE_DEVELOPER_MODE`
  /// value can never accidentally ship developer tooling to a production
  /// build - see docs/11_ENVIRONMENT_CONFIGURATION.md §8.
  factory AppConfig.forEnvironment(
    Environment environment, {
    bool developerModeForcedOff = false,
  }) {
    final dataSourceMode = _dataSourceModeOverride.isEmpty
        ? DataSourceMode.mock
        : DataSourceMode.values.byName(_dataSourceModeOverride);

    final logLevel = _logLevelOverride.isEmpty
        ? _defaultLogLevelFor(environment)
        : LogLevel.values.byName(_logLevelOverride);

    final isDeveloperModeAvailable =
        !developerModeForcedOff &&
        (_developerModeOverride ?? _defaultDeveloperModeFor(environment));

    return AppConfig(
      environment: environment,
      dataSourceMode: dataSourceMode,
      logLevel: logLevel,
      mockLatencyMin: const Duration(milliseconds: _mockLatencyMinMsOverride),
      mockLatencyMax: const Duration(milliseconds: _mockLatencyMaxMsOverride),
      isDeveloperModeAvailable: isDeveloperModeAvailable,
    );
  }

  /// The active deployment stage.
  final Environment environment;

  /// Which repository bindings DI should select - see
  /// docs/05_ARCHITECTURE_GUIDELINES.md §7.
  final DataSourceMode dataSourceMode;

  /// Minimum [LogLevel] the registered `AppLogger` should emit.
  final LogLevel logLevel;

  /// Lower bound of the artificial latency mock data sources simulate.
  final Duration mockLatencyMin;

  /// Upper bound of the artificial latency mock data sources simulate.
  final Duration mockLatencyMax;

  /// Gates the Developer Panel and Tenant Switcher route/menu registration.
  /// Always `false` for a `prod`-flavor build - see
  /// docs/11_ENVIRONMENT_CONFIGURATION.md §8.
  final bool isDeveloperModeAvailable;

  /// When `true`, the storefront app shows a maintenance screen instead of
  /// its normal routes. Not yet exposed via `--dart-define` (Phase 1 scope
  /// has no remote-config channel to flip this without a rebuild) - see
  /// docs/09_ROUTING_PLAN.md.
  final bool storefrontMaintenanceMode;

  /// Same as [storefrontMaintenanceMode], for the admin app.
  final bool adminMaintenanceMode;

  static const String _dataSourceModeOverride = String.fromEnvironment(
    'DATA_SOURCE_MODE',
  );

  static const String _logLevelOverride = String.fromEnvironment('LOG_LEVEL');

  static const bool _hasDeveloperModeOverride = bool.hasEnvironment(
    'ENABLE_DEVELOPER_MODE',
  );

  static const bool _developerModeOverrideValue = bool.fromEnvironment(
    'ENABLE_DEVELOPER_MODE',
  );

  static bool? get _developerModeOverride =>
      _hasDeveloperModeOverride ? _developerModeOverrideValue : null;

  static const int _mockLatencyMinMsOverride = int.fromEnvironment(
    'MOCK_LATENCY_MIN_MS',
    defaultValue: 300,
  );

  static const int _mockLatencyMaxMsOverride = int.fromEnvironment(
    'MOCK_LATENCY_MAX_MS',
    defaultValue: 800,
  );

  static LogLevel _defaultLogLevelFor(Environment environment) =>
      switch (environment) {
        Environment.dev => LogLevel.debug,
        Environment.staging => LogLevel.info,
        Environment.prod => LogLevel.warning,
      };

  static bool _defaultDeveloperModeFor(Environment environment) =>
      switch (environment) {
        Environment.dev => true,
        Environment.staging => true,
        Environment.prod => false,
      };

  @override
  List<Object?> get props => [
    environment,
    dataSourceMode,
    logLevel,
    mockLatencyMin,
    mockLatencyMax,
    isDeveloperModeAvailable,
    storefrontMaintenanceMode,
    adminMaintenanceMode,
  ];
}
