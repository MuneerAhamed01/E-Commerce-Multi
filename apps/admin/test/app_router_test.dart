import 'package:admin/app/app_router.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

TenantConfig _tenant() {
  return TenantConfig(
    tenantId: 'default',
    displayName: 'Test Admin',
    branding: const BrandingTokens(
      primaryColorHex: '#2563EB',
      secondaryColorHex: '#F97316',
      logoAssetPath: 'assets/logo.png',
    ),
    copy: const CopyOverrides.empty(),
    featureFlags: FeatureFlagSet.allEnabled(),
    defaultLocale: 'en_US',
    supportEmail: 'a@b.c',
    allowGuestBrowsing: true,
    allowGuestCart: true,
  );
}

AppConfig _config() {
  return const AppConfig(
    environment: Environment.dev,
    dataSourceMode: DataSourceMode.mock,
    logLevel: LogLevel.debug,
    mockLatencyMin: Duration(milliseconds: 1),
    mockLatencyMax: Duration(milliseconds: 2),
    isDeveloperModeAvailable: true,
  );
}

void main() {
  testWidgets('initial route is admin login for guest session', (tester) async {
    final router = createAdminRouter(
      appConfig: _config(),
      tenantConfig: _tenant(),
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(router.state.matchedLocation, SystemRoutes.adminLoginPath);
    expect(find.text('Admin Login'), findsWidgets);
  });

  testWidgets('dashboard redirects guests to login', (tester) async {
    final router = createAdminRouter(
      appConfig: _config(),
      tenantConfig: _tenant(),
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    router.go(SystemRoutes.adminDashboardPath);
    await tester.pumpAndSettle();

    expect(router.state.matchedLocation, SystemRoutes.adminLoginPath);
  });

  testWidgets('unknown admin path shows 404', (tester) async {
    final router = createAdminRouter(
      appConfig: _config(),
      tenantConfig: _tenant(),
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    router.go('/admin/nope');
    await tester.pumpAndSettle();

    expect(find.text('Page not found'), findsOneWidget);
  });
}
