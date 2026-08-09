import 'package:authentication/authentication.dart';
import 'package:cart/cart.dart';
import 'package:categories/categories.dart';
import 'package:core/core.dart';
import 'package:products/products.dart';
import 'package:search/search.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wishlist/wishlist.dart';

/// Minimal auth stack for storefront router widget tests.
final class RouterTestAuth {
  RouterTestAuth._({
    required this.config,
    required this.tenant,
    required this.bloc,
    required this.listenable,
  });

  final AppConfig config;
  final TenantConfig tenant;
  final AuthBloc bloc;
  final AuthSessionListenable listenable;

  AuthSessionState sessionOf() => AuthSessionMapper.fromAuthState(bloc.state);

  Future<void> setOnboardingSeen() =>
      getIt<SetOnboardingSeen>()(const SetOnboardingSeenParams(seen: true));

  static Future<RouterTestAuth> create({bool allowGuestBrowsing = true}) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await getIt.reset();
    configureCoreInjection();

    const config = AppConfig(
      environment: Environment.dev,
      dataSourceMode: DataSourceMode.mock,
      logLevel: LogLevel.debug,
      mockLatencyMin: Duration.zero,
      mockLatencyMax: Duration.zero,
      isDeveloperModeAvailable: true,
    );
    final tenant = TenantConfig(
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
      allowGuestBrowsing: allowGuestBrowsing,
      allowGuestCart: true,
    );

    getIt.registerSingleton<AppConfig>(config);
    getIt.registerSingleton<TenantConfig>(tenant);
    getIt.registerSingleton<FeatureFlagService>(
      FeatureFlagService(flags: tenant.featureFlags),
    );
    configureMockInjection();
    getIt<MockDeveloperControls>().latencyDisabled = true;
    await configureAuthenticationInjection(preferences: prefs);
    configureProductsInjection();
    configureCategoriesInjection();
    configureSearchInjection();
    configureWishlistInjection();
    configureCartInjection();

    final bloc = getIt<AuthBloc>()..add(const AuthStarted());
    await bloc.stream.firstWhere(
      (s) => s is AuthUnauthenticated || s is AuthAuthenticated,
    );

    return RouterTestAuth._(
      config: config,
      tenant: tenant,
      bloc: bloc,
      listenable: AuthSessionListenable(bloc),
    );
  }

  Future<void> dispose() async {
    listenable.dispose();
    await getIt.reset();
  }
}
