# core

Cross-cutting infrastructure for the White Label Commerce Platform. Pure
Dart, zero outward dependencies (no Flutter, no feature package, no app).

See `docs/02_PROJECT_STRUCTURE.md` §4 and `docs/05_ARCHITECTURE_GUIDELINES.md`
for the full specification.

## What's here (through Phase 6)

| Folder | Contents |
|---|---|
| `config/` | `AppConfig` (env-aware, `--dart-define`-backed), `TenantConfig`/`BrandingTokens`/`CopyOverrides` (bundled-JSON-backed), `FeatureFlag`/`FeatureFlagSet`/`FeatureFlagService` |
| `routing/` | `RouteGuard`, `AuthSessionState`, `AdminPermission`, `SystemRoutes` (pure Dart — no `go_router` dependency) |
| `mock/` | `MockNetworkSimulator`, `MockDataSourceMixin`, `MockDeveloperControls`, shared `SeedData`/`MockSeedStore`, `configureMockInjection()`, and the reference ping stack under `mock/example/` |
| `error/` | `Failure` (sealed, typed error contract), `AppException` (data-layer-only exceptions), `Result<F, S>` (Either-style outcome) |
| `usecase/` | `UseCase<Type, Params>` / `StreamUseCase<Type, Params>` callable-class base contracts, shared `NoParams` |
| `pagination/` | `PaginatedResult<T>` - shared list envelope for every repository |
| `di/` | `getIt` service locator + `configureCoreInjection()` (injectable-generated) |
| `logging/` | `AppLogger` abstraction + `ConsoleAppLogger` default implementation (level-filterable via `setMinLevel()`) |
| `network/` | `NetworkInfo` (+ `AlwaysOnlineNetworkInfo` default) and the `ApiClient` contract (unimplemented until a real backend integration phase) |
| `shared_entities/` | `Money`, `Address` - cross-feature value objects with no single owner |
| `utils/` | `Validators`, `Formatters` |

### Mock data pattern (Phase 6)

Feature mock data sources should:

1. Inject `MockNetworkSimulator` (and usually `MockSeedStore`).
2. `with MockDataSourceMixin` and wrap each async call in `guarded('feature.action', ...)`.
3. Throw `AppException` subtypes on failure; repositories catch and map to `Failure`.
4. Register an in-memory store via `MockDeveloperControls.registerResetListener` (or construct `MockSeedStore` with controls) so the Developer Panel can reset fixtures.

Call `configureMockInjection()` from app `bootstrap()` **after** registering `AppConfig`.

`AppConfig.forEnvironment()` is the only place in the codebase allowed to
call `String`/`int`/`bool.fromEnvironment` - see
`docs/11_ENVIRONMENT_CONFIGURATION.md` §3 and §5. `TenantConfig` is loaded
by each app's `bootstrap.dart` from a bundled JSON asset (`config/tenants/`
at the repo root, symlinked into each app - see
`docs/11_ENVIRONMENT_CONFIGURATION.md` §6), not from inside `core` itself
(`core` stays Flutter-free, so it can't call `rootBundle`).

## Regenerating the DI config

After adding a new `@Injectable`/`@LazySingleton` class:

```bash
fvm dart run build_runner build --delete-conflicting-outputs
```

This regenerates `lib/di/injection_container.config.dart`, which is
committed (not gitignored) so consumers don't need `build_runner` on every
checkout.
