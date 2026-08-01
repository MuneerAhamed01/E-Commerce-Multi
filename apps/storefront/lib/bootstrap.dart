import 'package:flutter/material.dart';

import 'app/app_widget.dart';

/// Shared startup sequence for the Storefront app, invoked by every
/// `main_<flavor>.dart` entry point so those files stay trivial
/// (see docs/02_PROJECT_STRUCTURE.md §3).
///
/// This is a Phase 1 (Project Foundation) placeholder. The real sequence
/// (load `AppConfig`/`TenantConfig`, init `AppLogger`, init DI, register
/// feature injection modules, build `AppTheme`, wrap in an error zone) is
/// added across Phase 2 (Core Architecture), Phase 3 (Environment &
/// Configuration), and Phase 4 (Design System) - see
/// docs/03_DEVELOPMENT_PHASES.md and docs/11_ENVIRONMENT_CONFIGURATION.md §10.
Future<void> bootstrap({required String flavor}) async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(AppWidget(flavor: flavor));
}
