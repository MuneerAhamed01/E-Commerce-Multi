import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection_container.config.dart';

/// The single, shared service locator instance for the whole platform.
///
/// Both `apps/storefront` and `apps/admin`, and every feature package,
/// resolve their dependencies through this one instance - see
/// docs/05_ARCHITECTURE_GUIDELINES.md §7.
final GetIt getIt = GetIt.instance;

/// Registers every `@Injectable`/`@LazySingleton`/`@Factory`-annotated
/// class declared inside `packages/core` (currently [ConsoleAppLogger] and
/// [AlwaysOnlineNetworkInfo]) into [getIt].
///
/// Each feature package exposes its own `configure<Feature>Injection()`
/// entry point following this exact pattern (a plain function wrapping a
/// generated, package-scoped injectable init - or a hand-written
/// `<Feature>InjectionModule` for features with no codegen needs). The app
/// shell's `app_injection.dart` calls this one first, then every feature's
/// entry point in dependency order, during `bootstrap()` - see
/// docs/02_PROJECT_STRUCTURE.md §3 and docs/05_ARCHITECTURE_GUIDELINES.md §7.
///
/// The app shell never registers a feature's (or core's) internals
/// directly - it only calls this public registration entry point.
@InjectableInit(
  initializerName: 'initCore',
  preferRelativeImports: true,
  asExtension: false,
)
void configureCoreInjection() => initCore(getIt);
