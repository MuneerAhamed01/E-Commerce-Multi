import 'dart:math';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

TenantConfig _tenant() {
  return TenantConfig(
    tenantId: 'default',
    displayName: 'Default Tenant',
    branding: const BrandingTokens(
      primaryColorHex: '#0B6E4F',
      secondaryColorHex: '#08A045',
      logoAssetPath: 'assets/logo.png',
      fontFamily: 'Roboto',
    ),
    copy: const CopyOverrides.empty(),
    featureFlags: FeatureFlagSet.allEnabled(),
    defaultLocale: 'en_US',
    supportEmail: 'support@example.com',
    allowGuestBrowsing: true,
    allowGuestCart: true,
  );
}

AppConfig _config() {
  return const AppConfig(
    environment: Environment.dev,
    dataSourceMode: DataSourceMode.mock,
    logLevel: LogLevel.debug,
    mockLatencyMin: Duration.zero,
    mockLatencyMax: Duration.zero,
    isDeveloperModeAvailable: true,
  );
}

({
  GetPing getPing,
  MockDeveloperControls controls,
  MockSeedStore store,
  MockNetworkSimulator simulator,
})
_buildStack({bool forcePingFailure = false}) {
  final controls = MockDeveloperControls()..latencyDisabled = true;
  if (forcePingFailure) {
    controls.forceFailure(MockCallTypes.ping);
  }
  final store = MockSeedStore(controls: controls);
  final simulator = MockNetworkSimulator(
    appConfig: _config(),
    controls: controls,
    random: Random(0),
  );
  final getPing = GetPing(
    MockPingRepository(
      MockPingRemoteDataSource(simulator: simulator, store: store),
    ),
  );
  return (
    getPing: getPing,
    controls: controls,
    store: store,
    simulator: simulator,
  );
}

Future<void> _pumpPanel(
  WidgetTester tester, {
  bool forcePingFailure = false,
}) async {
  final stack = _buildStack(forcePingFailure: forcePingFailure);
  final tenant = _tenant();
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light(tenant),
      home: DeveloperPanelPage(
        appConfig: _config(),
        tenantConfig: tenant,
        getPing: stack.getPing,
        controls: stack.controls,
        store: stack.store,
        simulator: stack.simulator,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _tapRunPing(WidgetTester tester) async {
  final runPing = find.text('Run ping');
  await tester.scrollUntilVisible(
    runPing,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
  await tester.tap(runPing);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders env summary and runs ping successfully', (tester) async {
    await _pumpPanel(tester);

    expect(find.text('Developer Panel'), findsOneWidget);
    expect(find.text('default'), findsWidgets);

    await _tapRunPing(tester);

    expect(find.textContaining('pong from mock data source'), findsOneWidget);
  });

  testWidgets('force ping failure surfaces error state', (tester) async {
    await _pumpPanel(tester, forcePingFailure: true);

    await _tapRunPing(tester);

    expect(find.textContaining('Failure:'), findsOneWidget);
  });
}
