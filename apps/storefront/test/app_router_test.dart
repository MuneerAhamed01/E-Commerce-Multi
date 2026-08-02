import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:storefront/app/app_router.dart';

TenantConfig _tenant() {
  return TenantConfig(
    tenantId: 'default',
    displayName: 'Test Store',
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
  testWidgets('splash redirects to home and shell shows Home', (tester) async {
    final router = createStorefrontRouter(
      appConfig: _config(),
      tenantConfig: _tenant(),
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsWidgets);
    expect(router.state.matchedLocation, SystemRoutes.storefrontHomePath);
  });

  testWidgets('unknown path shows 404 with go-home CTA', (tester) async {
    final router = createStorefrontRouter(
      appConfig: _config(),
      tenantConfig: _tenant(),
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    router.go('/this-route-does-not-exist');
    await tester.pumpAndSettle();

    expect(find.text('Page not found'), findsOneWidget);
    expect(find.text('Go home'), findsOneWidget);
  });

  testWidgets('wishlist redirects guests to login', (tester) async {
    final router = createStorefrontRouter(
      appConfig: _config(),
      tenantConfig: _tenant(),
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    router.go('/wishlist');
    await tester.pumpAndSettle();

    expect(router.state.matchedLocation, SystemRoutes.storefrontLoginPath);
    expect(find.text('Login'), findsWidgets);
  });
}
