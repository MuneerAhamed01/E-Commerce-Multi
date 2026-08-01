# 05 — Architecture Guidelines

**Status:** Planning document. Defines the binding architectural rules for every package and app in the platform. `06_DEVELOPMENT_RULES.md` restates the most critical of these as short, enforceable "never/always" rules; this document explains the *reasoning* behind them.

---

## 1. Clean Architecture

Every feature package is organized into three layers, each with a single responsibility and a strict, one-directional dependency rule:

```
Presentation  →  Domain  ←  Data
```

- **Domain** is the center. It knows nothing about Flutter, HTTP, Firebase, or `flutter_bloc`. It is pure Dart.
- **Presentation** depends on Domain (entities, use cases) to get and manipulate data, and depends on `design_system`/`core` for UI primitives. It never depends on Data directly.
- **Data** depends on Domain (to implement its repository interfaces) and on `core` (for network/error primitives). It never depends on Presentation.

This is the **Dependency Rule**: source code dependencies point only inward, toward Domain. Domain has zero outward dependencies. This is what makes Domain logic testable without Flutter, without a database, and without a UI.

## 2. The Dependency Rule, Concretely

| Layer | May import | Must NOT import |
|---|---|---|
| Domain | `dart:core`, `core` package's pure-Dart primitives (`Result`, `Failure`, `UseCase`) | `flutter/material.dart`, `flutter_bloc`, any `data/` file, any `presentation/` file, `firebase_*`, `go_router` |
| Data | Domain (same feature), `core` (network, error, logging) | `presentation/` (same feature), `flutter_bloc`, `go_router`, another feature's `data/` or `domain/` internals |
| Presentation | Domain (same feature), `design_system`, `core` (config, DI), `flutter_bloc`, `go_router` | `data/` (same feature) — no importing `*RepositoryImpl`, `*DataSource`, or DTO `*Model` classes directly; only entities and use cases |

Enforcement mechanism: import-boundary review is a mandatory line item in every milestone's review checklist (`03_DEVELOPMENT_PHASES.md`). Where tooling allows (e.g., a lint rule or custom `import_lint` configuration), boundary violations should fail static analysis, not just human review.

## 3. Feature Isolation

- A feature package's `src/` directory is implementation detail. Only what is re-exported from `<feature_name>.dart` (the barrel file) is a public contract other packages may depend on.
- Cross-feature dependencies are **domain-to-domain only**, and only when explicitly declared in `04_FEATURE_IMPLEMENTATION_ORDER.md`'s "Dependencies" field (e.g., `admin_catalog` depends on `products`'s domain). A feature's presentation layer never imports another feature's presentation, data, or internal domain classes directly — it goes through the dependent feature's public barrel export.
- Widgets are only shared upward into `design_system` once proven reusable across ≥2 features; until then they stay feature-local in `presentation/widgets/`.
- Truly universal entities that have no single feature owner (`Money`, `Address`, `PaginatedResult<T>`) live in `packages/core/lib/shared_entities/` — this is a deliberate, narrow exception to "domain lives inside its feature," reserved for concepts with no natural single owner.

## 4. Presentation Layer Rules

- Contains: Screens (routed, full-page widgets), feature-local widgets, Blocs/Cubits, and the feature's `go_router` route definitions.
- **No business logic in widgets.** A widget's `build()` method only reads Bloc/Cubit state and dispatches events/calls methods. Any computation beyond simple display formatting (e.g., "is this button enabled") belongs in the Bloc/Cubit or, if it's a business rule, in a use case.
- **One Bloc/Cubit per cohesive UI concern**, not one per screen dogmatically and not one giant app-wide Bloc. A screen may compose multiple Cubits (e.g., a filter Cubit + a results Bloc) when concerns are genuinely separable.
- **Bloc vs Cubit decision rule:** Use `Cubit` when state changes are simple method calls with no need to react to multiple event *types* asynchronously (e.g., `WishlistCubit.toggle(productId)`). Use `Bloc` when there are multiple distinct event types, event transformation (debounce/throttle), or complex state machines (e.g., `SearchBloc`, `CheckoutBloc`).
- Screens never instantiate repositories or data sources directly — they receive Blocs/Cubits via DI (`get_it`, resolved through `BlocProvider`/`RepositoryProvider` wiring at the route or app-shell level).
- Screens accept navigation parameters via `go_router`'s typed extra/path parameters, not via global mutable state.

## 5. Domain Layer Rules

- **Entities** are immutable (`freezed` or manually `final`-field classes with `Equatable`), have no serialization logic (`toJson`/`fromJson` live on Data-layer Models, not Entities), and contain only business-meaningful fields and, where appropriate, simple derived getters (e.g., `Order.isCancellable`).
- **Repository interfaces** are abstract classes declaring the operations a feature needs, in domain terms (`Future<Result<Failure, Product>> getProductDetail(String id)`), never in transport terms (no `Map<String, dynamic>`, no HTTP status codes, no Firestore `DocumentSnapshot`).
- **Use cases** each expose a single `call(Params params)` method (callable class pattern), do exactly one thing, and are named as verbs (`PlaceOrder`, not `OrderManager`). A use case may compose multiple repository calls but must not reach into another feature's repository directly unless that dependency is documented (§3).
- **Failures** are typed, feature-aware sealed classes extending a shared `Failure` base from `core` (e.g., `ServerFailure`, `CacheFailure`, `ValidationFailure(fieldErrors)`, `InsufficientStockFailure`), never raw `Exception`/`String` messages surfaced to the UI.

## 6. Data Layer Rules

- **Data sources** are the only place that knows about a specific data origin (mock in-memory, Firebase, REST). Each feature declares a data source **interface** even for mock-only Phase 1 work, so a later `Firebase*DataSource` can be added without touching the repository implementation's structure.
- **Repository implementations** translate data-source results/exceptions into domain `Result<Failure, T>` and Models into Entities. This translation boundary is the *only* place `try/catch` around data-source exceptions is allowed.
- **Models (DTOs)** mirror the anticipated Firestore document shape (flat where possible, explicit field names matching planned collection schema — see `10_DATA_FLOW.md`) and carry `fromJson`/`toJson`/`fromEntity`/`toEntity` mapping. Entities never import Models; Models import Entities (one-directional mapping).
- **Mock data sources** must simulate realistic asynchronous behavior: artificial latency (configurable, e.g., 300–800ms), and deterministic failure injection hooks (e.g., a query param or dev-panel toggle to force a `ServerFailure`) so error-state UI is exercised during development, not just at the end.

## 7. Dependency Injection

- **Tooling:** `get_it` as the service locator, `injectable` for annotation-driven registration and codegen, avoiding hundreds of hand-written `getIt.registerLazySingleton` calls.
- **Registration scope rules:**
  - Repositories, data sources, and use cases: `registerLazySingleton` (one instance per app lifetime) unless a feature explicitly needs per-navigation-scope state (rare; document if so).
  - Blocs/Cubits tied to a single screen's lifecycle: `registerFactory` (new instance per screen), provided via `BlocProvider(create: () => getIt<XBloc>())` at the route level.
  - Blocs/Cubits that must persist across the whole authenticated session (`AuthBloc`, `CartBloc`, `WishlistCubit`, `NotificationBloc`): `registerLazySingleton`, provided once at the app-shell root via `MultiBlocProvider`.
- **Module composition:** Each feature exposes a `<Feature>InjectionModule` (an `@module` abstract class or a plain registration function) that the app shell's `app_injection.dart` calls during bootstrap. The app shell never registers a feature's internals directly — it only calls that feature's public registration entry point.
- **Environment-based binding swap:** The seam between Mock and Firebase implementations is a single `get_it` registration line per repository, selected by `AppConfig.dataSourceMode` (`mock` | `firebase`). No `if (isMock)` branching is ever written inside feature code — see §13.

## 8. Repository Pattern

- Every repository has exactly one abstract interface (Domain) and at minimum one concrete implementation (`Mock*RepositoryImpl`, Data layer). A `Firebase*RepositoryImpl` stub (throwing `UnimplementedError` or with real Firebase calls once that later project phase begins) is added at the same location and swapped in via DI, never via editing the mock class.
- Repositories return `Future<Result<Failure, T>>` (or `Stream<Result<Failure, T>>` for realtime-shaped data such as Notifications or Order status, anticipating Firestore snapshots later) — never raw `T` with thrown exceptions, and never `T?` with silent nulls for error cases.
- List-returning repository methods return `PaginatedResult<T>` (from `core`), carrying items, a cursor/next-page token, and a total-count-if-known field, so pagination UI is identical whether backed by mock data or Firestore's `startAfter` cursor pattern.

## 9. Use Case Pattern

```
abstract class UseCase<Type, Params> {
  Future<Result<Failure, Type>> call(Params params);
}
class NoParams {}
```

- One class per use case, single public `call()` method, invoked as `useCase(params)` via Dart's callable-class syntax for readability in Blocs.
- Use cases are the **only** thing a Bloc/Cubit is allowed to depend on from the domain layer of its own feature (Blocs never call a repository directly), keeping a single seam for testing (mock the use case, not the repository, in Bloc tests) and a single seam for cross-cutting concerns (logging, analytics events can be added inside a use case's `call()` uniformly).
- Use cases with no parameters use a shared `NoParams` marker class from `core` rather than each feature inventing its own.

## 10. State Management Rules

- `flutter_bloc` is the only sanctioned state management approach for business/application state. `setState` is permitted **only** for purely ephemeral, presentation-only state with no business meaning and no persistence requirement (e.g., a `TextField`'s focus ripple, a local `PageController` position, an expand/collapse animation flag).
- Bloc/Cubit `state` classes are immutable (`freezed` sealed unions or `Equatable` subclasses), enabling `bloc_test`'s state-sequence assertions and preventing accidental partial-state mutation bugs.
- Every Bloc's states model **at minimum**: `Initial`, `Loading`, `Loaded(data)`, `Empty` (where applicable), `Error(failure)` — mapped directly to the mandatory loading/empty/error screen states (§`06_DEVELOPMENT_RULES.md`).
- Bloc-to-Bloc communication happens via stream subscription (`BlocListener` triggering another Bloc's event, or an injected shared use case/repository stream) — never by one Bloc directly holding a reference to another Bloc's internals.
- No Bloc/Cubit ever imports `flutter/material.dart` beyond `Color`/`IconData`-free value types if strictly necessary; ideally zero Flutter UI imports in the Bloc layer at all, keeping it unit-testable without a widget test harness.

## 11. Naming Standards

Naming is fixed once, in `02_PROJECT_STRUCTURE.md` §10, and applies uniformly across every package. This document does not repeat it — see that section for the canonical table (files, classes, use cases, repositories, DTOs, routes, tests).

## 12. Code Standards

- Lint baseline: `flutter_lints` extended with stricter rules (`avoid_print`, `prefer_const_constructors`, `always_declare_return_types`, `public_member_api_docs` enabled for `packages/core` and `packages/design_system` public APIs at minimum).
- **Every public class, method, and property in `core`, `design_system`, and every feature's domain layer must have a `///` doc comment** explaining its purpose — not restating its name. Presentation-layer widget classes should have a doc comment when their purpose isn't obvious from the name plus one usage example in complex cases.
- Files are kept under ~300 lines as a soft guideline; a file exceeding this is a signal to extract a widget, mixin, or helper — not a hard blocker, but flagged in review.
- No commented-out code committed. No `// TODO` without an associated tracked milestone/issue reference.
- Formatting via `dart format`, enforced via `melos run format --set-exit-if-changed` as a pre-merge gate.

## 13. Error Handling

- **Layered translation:** Data-layer exceptions (network, cache, parsing) are caught at the repository-implementation boundary and converted into typed `Failure`s. Nothing above the repository implementation ever catches a raw `Exception`.
- **Domain-level failures** carry enough structured information for the UI to react specifically (e.g., `ValidationFailure(Map<String, String> fieldErrors)` lets a form show per-field errors; `InsufficientStockFailure(int availableQty)` lets the Cart UI show the exact number available).
- **Presentation-level handling:** Blocs map `Failure` → a user-facing message via a `FailureMessageMapper` (in `core`, extensible per feature) so error copy is centralized, tenant-copy-overridable (see `TenantConfig.copyOverrides`), and never hardcoded string literals scattered across widgets.
- **Global safety net:** `bootstrap.dart` wraps `runApp` in a Zone/`runZonedGuarded` plus `FlutterError.onError`, routing uncaught errors to `AppLogger` (and, later, Crashlytics) rather than crashing silently or showing a raw red screen in release mode.

## 14. Logging

- A single `AppLogger` abstraction in `core` with levels (`debug`, `info`, `warning`, `error`) and structured context (feature name, optional user/tenant id — never PII like email/full name in logs).
- Debug/staging: console output. Production: routes to a sink to be wired in the later backend-integration phase (Crashlytics/remote logging) — the call sites never change, only the sink implementation, following the same swap pattern as repositories.
- Logging is never used as a substitute for typed error handling (§13); it is observability, not control flow.

## 15. Configuration

- **`AppConfig`** (per environment/flavor): API base URLs (unused in Phase 1 but defined), `dataSourceMode` (`mock`/`firebase`), `isDeveloperModeAvailable`, log level, mock-latency simulation settings.
- **`TenantConfig`** (per client): branding tokens (colors, logo, font family reference), copy overrides, enabled feature set, default locale, contact/support info. Loaded once at bootstrap based on a build-time or runtime tenant selector (see `11_ENVIRONMENT_CONFIGURATION.md`).
- **`FeatureFlags`**: a flat, tenant-overridable `Map<String, bool>` (or typed subclass) evaluated via a single `FeatureFlagService.isEnabled(FeatureFlag.wishlist)` call site pattern — features check this at the router-registration level (hide the route entirely) and, redundantly, at the nav-entry level (hide the menu item), never only one or the other.
- Configuration objects are immutable and loaded once per app session; changing tenant/environment requires an app restart in Phase 1 (hot-swapping config at runtime, as demonstrated in the Tenant Management "Live Preview," is a controlled exception scoped to that admin screen only, not a general capability).

## 16. Environment

- Three environments: `dev`, `staging`, `prod` — each with its own Flutter flavor/entry point per app, its own `AppConfig`, and (later) its own Firebase project. Full detail in `11_ENVIRONMENT_CONFIGURATION.md`.
- `dev` defaults to `dataSourceMode = mock` always. `staging`/`prod` are architecturally capable of `dataSourceMode = firebase` once that integration phase exists, but remain `mock` throughout this plan's scope.

## 17. Scalability Rules

- **Package-per-feature** keeps compile times and cognitive load bounded as the platform grows to dozens of features — a change to `wishlist` never triggers recompilation of `checkout`.
- **No God Blocs.** If a Bloc's event enum exceeds ~10-12 events or its state class accumulates unrelated fields, split it — a sign the feature needs finer-grained Cubits/Blocs.
- **Table/list virtualization is mandatory** for any admin table or product grid beyond ~30 items (`ListView.builder`/`GridView.builder`/paginated data tables), never `Column` with `.map()` over a large collection.
- **New tenants must never require a new app build variant.** Tenant differences are data (`TenantConfig`), not code (`if (tenant == 'acme')`). Any code branch keyed on tenant identity is an architecture violation, flagged in review.
- **New features must never require modifying `core` or `design_system`'s existing public API**, only extending them (new token, new component) — breaking changes to shared packages require an ADR (`docs/adr/`).

## 18. Future Backend Integration Strategy

This plan explicitly defers live Firebase integration (`01_IMPLEMENTATION_PLAN.md` §4.2). The following is fixed now so that deferral is safe:

1. **Contracts first, implementation later.** Every repository interface, DTO shape, and pagination contract is designed as if Firestore already existed (async, cursor-paginated, typed failures for permission/network/not-found). The `Firebase*DataSource` and `Firebase*RepositoryImpl` classes are added as new files implementing the *existing* interface — no interface signature changes expected.
2. **DTO shape mirrors planned Firestore schema.** Each feature's `data/models/*.dart` documents (in a comment header) the anticipated Firestore collection/document path and field names, so the eventual mapping is a translation exercise, not a redesign (see `10_DATA_FLOW.md` §6 for the collection map).
3. **Auth swap is isolated.** `AuthRepository`'s `MockAuthRepositoryImpl` is replaced by a `FirebaseAuthRepositoryImpl` wrapping `firebase_auth`; session persistence swaps from local mock storage to Firebase's built-in session persistence behind the same `AuthSession` entity.
4. **Realtime-shaped repositories use `Stream` from day one** (Orders status, Notifications, Inventory levels) even though the mock implementation just uses a `StreamController` fed by local mutations — this means switching to `snapshots()` from Firestore requires no consumer-side (Bloc) changes.
5. **File storage seam:** Any image upload (Admin Catalog product images, Tenant branding logo) is defined behind a `FileStorageRepository` interface from the start, with a `MockFileStorageRepositoryImpl` (returns local asset/placeholder URLs), ready for a `FirebaseStorageRepositoryImpl` swap.
6. **Cloud Functions / server-side logic seam:** Any business rule that *should* eventually run server-side for integrity (order total recomputation, coupon redemption atomicity, stock decrement) is isolated inside a single use case (`PlaceOrder`, `ApplyPromoCode`, `AdjustStock`) so that, later, that use case's implementation can call a Cloud Function instead of local logic without changing its call sites.
7. **The backend integration project is explicitly out of scope here** but is set up to be a repository-implementation-and-DI-binding exercise, not a UI or domain rewrite — this is the measurable proof point that this architecture succeeded.

---

## 19. Summary Diagram (Textual)

```
┌─────────────────────────── Presentation ───────────────────────────┐
│  Screens • Widgets • Bloc/Cubit • go_router routes                 │
│  depends on ↓                                                       │
├─────────────────────────────  Domain  ──────────────────────────────┤
│  Entities • Repository Interfaces • Use Cases • Failures            │
│  (pure Dart, zero outward deps)                                     │
├─────────────────────────────  Data  ────────────────────────────────┤
│  Models(DTO) • DataSource(Mock/Firebase) • RepositoryImpl            │
│  implements ↑ Domain interfaces                                     │
└──────────────────────────────────────────────────────────────────────┘
        ▲                                   ▲
        │ registers via DI                  │ registers via DI
        └──────────── get_it / injectable ──┘
```
