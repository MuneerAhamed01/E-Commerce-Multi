import 'dart:developer' as developer;

import 'package:injectable/injectable.dart';

/// Severity levels for [AppLogger] calls, in increasing order of urgency.
enum LogLevel { debug, info, warning, error }

/// Cross-cutting logging abstraction used everywhere instead of `print` (or
/// any raw `Exception` catch without a log line).
///
/// Debug/staging route to the console (via [ConsoleAppLogger]); production
/// is wired to a real sink (Crashlytics/remote logging) in a later phase
/// without any call site changing - only the registered implementation
/// swaps, following the same DI-swap pattern as repositories. See
/// docs/05_ARCHITECTURE_GUIDELINES.md §14.
///
/// [feature] should be the feature package name (`'checkout'`, `'cart'`)
/// for structured filtering. Never log PII (email, full name) as [message]
/// or [error] - log an id instead.
abstract class AppLogger {
  void debug(
    String message, {
    String? feature,
    Object? error,
    StackTrace? stackTrace,
  });

  void info(
    String message, {
    String? feature,
    Object? error,
    StackTrace? stackTrace,
  });

  void warning(
    String message, {
    String? feature,
    Object? error,
    StackTrace? stackTrace,
  });

  void error(
    String message, {
    String? feature,
    Object? error,
    StackTrace? stackTrace,
  });
}

/// Default [AppLogger] implementation: writes structured lines to the
/// console via `dart:developer`'s `log()`, visible in `flutter run`'s
/// console and in DevTools. Sufficient for `dev`/`staging` throughout this
/// plan's mock-data phase - see docs/05_ARCHITECTURE_GUIDELINES.md §16.
@LazySingleton(as: AppLogger)
final class ConsoleAppLogger implements AppLogger {
  const ConsoleAppLogger();

  @override
  void debug(
    String message, {
    String? feature,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.debug,
      message,
      feature: feature,
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  void info(
    String message, {
    String? feature,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.info,
      message,
      feature: feature,
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  void warning(
    String message, {
    String? feature,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.warning,
      message,
      feature: feature,
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  void error(
    String message, {
    String? feature,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.error,
      message,
      feature: feature,
      error: error,
      stackTrace: stackTrace,
    );
  }

  void _log(
    LogLevel level,
    String message, {
    String? feature,
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: feature ?? 'app',
      level: _severity(level),
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Maps to the conventional `dart:developer` log-level integers so
  /// filtering by severity in DevTools/IDE consoles works as expected.
  int _severity(LogLevel level) => switch (level) {
    LogLevel.debug => 500,
    LogLevel.info => 800,
    LogLevel.warning => 900,
    LogLevel.error => 1000,
  };
}
