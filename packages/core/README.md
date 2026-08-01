# core

Cross-cutting infrastructure for the White Label Commerce Platform. Pure
Dart, zero outward dependencies (no Flutter, no feature package, no app).

See `docs/02_PROJECT_STRUCTURE.md` §4 and `docs/05_ARCHITECTURE_GUIDELINES.md`
for the full specification.

## What's here (Phase 2)

| Folder | Contents |
|---|---|
| `error/` | `Failure` (sealed, typed error contract), `AppException` (data-layer-only exceptions), `Result<F, S>` (Either-style outcome) |
| `usecase/` | `UseCase<Type, Params>` / `StreamUseCase<Type, Params>` callable-class base contracts, shared `NoParams` |
| `pagination/` | `PaginatedResult<T>` - shared list envelope for every repository |
| `di/` | `getIt` service locator + `configureCoreInjection()` (injectable-generated) |
| `logging/` | `AppLogger` abstraction + `ConsoleAppLogger` default implementation |
| `network/` | `NetworkInfo` (+ `AlwaysOnlineNetworkInfo` default) and the `ApiClient` contract (unimplemented until a real backend integration phase) |
| `shared_entities/` | `Money`, `Address` - cross-feature value objects with no single owner |
| `utils/` | `Validators`, `Formatters` |

`config/` (`AppConfig`/`TenantConfig`/`FeatureFlags`) is added in Phase 3.

## Regenerating the DI config

After adding a new `@Injectable`/`@LazySingleton` class:

```bash
fvm dart run build_runner build --delete-conflicting-outputs
```

This regenerates `lib/di/injection_container.config.dart`, which is
committed (not gitignored) so consumers don't need `build_runner` on every
checkout.
