import 'package:core/core.dart';
import 'package:test/test.dart';

TenantConfig _tenant({bool wishlist = true}) {
  return TenantConfig(
    tenantId: 'default',
    displayName: 'Test',
    branding: const BrandingTokens(
      primaryColorHex: '#2563EB',
      secondaryColorHex: '#F97316',
      logoAssetPath: 'assets/logo.png',
    ),
    copy: const CopyOverrides.empty(),
    featureFlags: FeatureFlagSet.fromJson({'wishlist': wishlist}),
    defaultLocale: 'en_US',
    supportEmail: 'a@b.c',
    allowGuestBrowsing: true,
    allowGuestCart: true,
  );
}

AppConfig _config({
  bool storefrontMaintenance = false,
  bool adminMaintenance = false,
  bool developerMode = true,
}) {
  return AppConfig(
    environment: Environment.dev,
    dataSourceMode: DataSourceMode.mock,
    logLevel: LogLevel.debug,
    mockLatencyMin: const Duration(milliseconds: 1),
    mockLatencyMax: const Duration(milliseconds: 2),
    isDeveloperModeAvailable: developerMode,
    storefrontMaintenanceMode: storefrontMaintenance,
    adminMaintenanceMode: adminMaintenance,
  );
}

void main() {
  group('RouteGuard.redirect', () {
    test('sends every non-maintenance route to /maintenance when flagged', () {
      final result = RouteGuard.redirect(
        RouteGuardInput(
          app: RouteAppKind.storefront,
          matchedLocation: '/home',
          access: RouteAccess.public,
          appConfig: _config(storefrontMaintenance: true),
          tenantConfig: _tenant(),
          session: const AuthSessionState.guest(),
        ),
      );

      expect(result, SystemRoutes.storefrontMaintenancePath);
    });

    test('does not bounce the maintenance screen itself', () {
      final result = RouteGuard.redirect(
        RouteGuardInput(
          app: RouteAppKind.storefront,
          matchedLocation: SystemRoutes.storefrontMaintenancePath,
          access: RouteAccess.maintenance,
          appConfig: _config(storefrontMaintenance: true),
          tenantConfig: _tenant(),
          session: const AuthSessionState.guest(),
        ),
      );

      expect(result, isNull);
    });

    test('redirects authenticated routes to login with redirect query', () {
      final result = RouteGuard.redirect(
        RouteGuardInput(
          app: RouteAppKind.storefront,
          matchedLocation: '/wishlist',
          access: RouteAccess.authenticated,
          appConfig: _config(),
          tenantConfig: _tenant(),
          session: const AuthSessionState.guest(),
        ),
      );

      expect(result, '/login?redirect=%2Fwishlist');
    });

    test('bounces authenticated users away from auth-flow routes', () {
      final result = RouteGuard.redirect(
        RouteGuardInput(
          app: RouteAppKind.storefront,
          matchedLocation: '/login',
          access: RouteAccess.authFlow,
          appConfig: _config(),
          tenantConfig: _tenant(),
          session: const AuthSessionState(isAuthenticated: true),
        ),
      );

      expect(result, SystemRoutes.storefrontHomePath);
    });

    test('honors ?redirect= after auth-flow bounce', () {
      final result = RouteGuard.redirect(
        RouteGuardInput(
          app: RouteAppKind.storefront,
          matchedLocation: '/login',
          access: RouteAccess.authFlow,
          appConfig: _config(),
          tenantConfig: _tenant(),
          session: const AuthSessionState(isAuthenticated: true),
          uri: Uri.parse('/login?redirect=%2Forders'),
        ),
      );

      expect(result, '/orders');
    });

    test('disabled feature flag yields not-found sentinel', () {
      final result = RouteGuard.redirect(
        RouteGuardInput(
          app: RouteAppKind.storefront,
          matchedLocation: '/wishlist',
          access: RouteAccess.authenticated,
          appConfig: _config(),
          tenantConfig: _tenant(wishlist: false),
          session: const AuthSessionState(isAuthenticated: true),
          requiredFeatureFlag: FeatureFlag.wishlist,
        ),
      );

      expect(result, '/__not_found__');
    });

    test('admin permission failure redirects to access-denied', () {
      final result = RouteGuard.redirect(
        RouteGuardInput(
          app: RouteAppKind.admin,
          matchedLocation: '/admin/catalog/products',
          access: RouteAccess.authenticated,
          appConfig: _config(),
          tenantConfig: _tenant(),
          session: const AuthSessionState(
            isAuthenticated: true,
            adminPermissions: {AdminPermission.orderManager},
          ),
          requiredPermission: AdminPermission.catalogManager,
        ),
      );

      expect(result, SystemRoutes.adminAccessDeniedPath);
    });

    test('developer route is not-found when developer mode is off', () {
      final result = RouteGuard.redirect(
        RouteGuardInput(
          app: RouteAppKind.storefront,
          matchedLocation: SystemRoutes.storefrontDevPanelPath,
          access: RouteAccess.developer,
          appConfig: _config(developerMode: false),
          tenantConfig: _tenant(),
          session: const AuthSessionState.guest(),
        ),
      );

      expect(result, '/__not_found__');
    });
  });

  group('RouteGuard.postLoginLocation', () {
    test('returns landing when no redirect query is present', () {
      expect(
        RouteGuard.postLoginLocation(
          app: RouteAppKind.admin,
          loginUri: Uri.parse('/admin/login'),
        ),
        SystemRoutes.adminDashboardPath,
      );
    });
  });

  group('AuthSessionState.hasPermission', () {
    test('anyAdmin requires a non-empty permission set', () {
      const emptyAuth = AuthSessionState(isAuthenticated: true);
      const withPerms = AuthSessionState(
        isAuthenticated: true,
        adminPermissions: {AdminPermission.catalogManager},
      );

      expect(emptyAuth.hasPermission(AdminPermission.anyAdmin), isFalse);
      expect(withPerms.hasPermission(AdminPermission.anyAdmin), isTrue);
      expect(withPerms.hasPermission(AdminPermission.catalogManager), isTrue);
    });
  });
}
