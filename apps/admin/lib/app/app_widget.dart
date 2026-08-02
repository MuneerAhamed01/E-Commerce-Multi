import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_router.dart';

/// Root widget of the Admin Panel app.
///
/// Phase 5: [MaterialApp.router] driven by [createAdminRouter]. Session is
/// guest until Phase 21 wires admin auth — shell destinations therefore
/// redirect to `/admin/login` via [RouteGuard].
class AppWidget extends StatefulWidget {
  const AppWidget({
    required this.appConfig,
    required this.tenantConfig,
    this.session = const AuthSessionState.guest(),
    super.key,
  });

  final AppConfig appConfig;
  final TenantConfig tenantConfig;
  final AuthSessionState session;

  @override
  State<AppWidget> createState() => _AppWidgetState();
}

class _AppWidgetState extends State<AppWidget> {
  late final GoRouter _router = createAdminRouter(
    appConfig: widget.appConfig,
    tenantConfig: widget.tenantConfig,
    session: widget.session,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '${widget.tenantConfig.displayName} Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(widget.tenantConfig),
      darkTheme: AppTheme.dark(widget.tenantConfig),
      routerConfig: _router,
    );
  }
}
