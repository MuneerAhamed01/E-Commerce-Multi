# 02 — Project Structure

**Status:** Planning document. No code exists yet; paths below are the mandatory target structure.

---

## 1. Topology Decision

The platform is a **Melos-managed Dart/Flutter monorepo** with two thin app shells and a set of shared packages.

**Why a monorepo with shared packages (not 3 separate apps, not 1 giant app):**

- Mobile and Web storefront share 100% of domain/data logic and the vast majority of presentation widgets (Flutter's responsive layout makes one storefront codebase serve both) → they are **one app target** (`apps/storefront`) built for multiple platforms.
- Admin Panel has materially different information architecture (tables, bulk actions, RBAC, analytics) and a different primary input model (desktop/web-first, mouse/keyboard) → it is a **separate app target** (`apps/admin`) so its shell, routing, and admin-only screens don't pollute the customer app bundle size or navigation graph.
- Both apps must share domain rules, entities, repositories, and design tokens byte-for-byte (a "Product" must mean the same thing in both apps) → these live in **shared packages**, imported by both apps.
- A monorepo (vs. multi-repo) keeps shared packages versioned and refactored atomically with their consumers, which matters for a white-label product where core contracts change over time.

## 2. Top-Level Layout

```
white-label-commerce-platform/
├── apps/
│   ├── storefront/                # Flutter app: Mobile (iOS/Android) + Web customer experience
│   └── admin/                     # Flutter app: Admin Panel (web-first, responsive to tablet/desktop)
├── packages/
│   ├── core/                      # Cross-cutting infrastructure, no UI
│   ├── design_system/             # Tokens, theming, shared component library
│   └── features/                  # One package per business feature (feature-first)
│       ├── authentication/
│       ├── dashboard/
│       ├── products/
│       ├── categories/
│       ├── search/
│       ├── wishlist/
│       ├── cart/
│       ├── checkout/
│       ├── orders/
│       ├── payments/
│       ├── notifications/
│       ├── profile/
│       ├── settings/
│       ├── support/
│       ├── admin_dashboard/
│       ├── admin_catalog/
│       ├── admin_inventory/
│       ├── admin_orders/
│       ├── admin_customers/
│       ├── marketing/
│       ├── analytics_reports/
│       └── tenant_management/
├── assets/                        # Shared, tenant-neutral default assets (see §7)
├── config/                        # Environment/tenant configuration files (see §8, and doc 11)
├── docs/                          # This documentation set
├── tool/                          # Repo-level scripts (codegen, lint, CI helpers)
├── melos.yaml                     # Monorepo workspace + script definitions
├── analysis_options.yaml          # Repo-wide lint baseline
└── README.md                      # Root index pointing into docs/
```

**Rationale for each top-level entry:**

| Entry | Why it exists |
|---|---|
| `apps/` | Deployable units. Nothing outside `apps/` is ever built/deployed directly. |
| `packages/` | Reusable, independently testable units. Nothing here imports from `apps/` (dependency rule flows one way — see doc 05). |
| `assets/` | Default/tenant-neutral images, fonts, lottie files, icons used before any tenant overrides are applied. |
| `config/` | Machine-readable environment and tenant configuration (JSON/YAML) consumed at bootstrap — see doc 11. |
| `docs/` | This planning/reference documentation set, kept alongside code so it stays version-controlled and current. |
| `tool/` | Scripts for codegen (`build_runner`), lint, formatting, and CI, kept out of app/package source. |
| `melos.yaml` | Declares the workspace, package globs, and cross-package scripts (`melos bootstrap`, `melos run analyze`, etc.). |
| `analysis_options.yaml` | One lint configuration inherited by every package — prevents drift between features. |

---

## 3. App Shell Structure (`apps/storefront` and `apps/admin`)

Both apps follow the **same internal skeleton**, differing only in which feature packages and design-system variant they consume.

```
apps/storefront/
├── lib/
│   ├── main_dev.dart              # Entry point: dev flavor
│   ├── main_staging.dart          # Entry point: staging flavor
│   ├── main_prod.dart             # Entry point: production flavor
│   ├── bootstrap.dart             # Shared startup: DI init, config load, error zone, runApp
│   ├── app/
│   │   ├── app_widget.dart        # Root MaterialApp.router widget
│   │   ├── app_router.dart        # go_router instance composed from feature route modules
│   │   └── app_shell.dart         # Bottom nav / persistent shell (customer app only)
│   └── injection/
│       └── app_injection.dart     # Registers app-shell-only dependencies; imports each feature's injection module
├── test/                          # App-shell-level widget/integration tests only
├── android/ ios/ web/ macos/ (etc.)# Flutter platform runners (generated by `flutter create`)
└── pubspec.yaml                   # Depends on: core, design_system, and every customer-facing feature package
```

```
apps/admin/
├── lib/
│   ├── main_dev.dart / main_staging.dart / main_prod.dart
│   ├── bootstrap.dart
│   ├── app/
│   │   ├── app_widget.dart
│   │   ├── app_router.dart
│   │   └── app_shell.dart         # Side nav / admin shell (desktop-first layout)
│   └── injection/
│       └── app_injection.dart
├── test/
├── web/ macos/ windows/ linux/ (Admin targets Web primarily; Desktop optional)
└── pubspec.yaml                   # Depends on: core, design_system, and every admin feature package
```

**Rule:** No business logic, no widgets beyond app-shell chrome (nav shell, splash), no repository or bloc implementations live inside `apps/*`. Apps only **compose** what packages provide.

**Why flavors as separate `main_*.dart` files:** keeps environment selection explicit and IDE-runnable (each is a valid Flutter entry point), while `bootstrap.dart` centralizes the actual startup sequence so the three files stay trivial (see doc 11 for flavor details).

---

## 4. Core Package Structure (`packages/core`)

```
packages/core/
├── lib/
│   ├── core.dart                       # Barrel export
│   ├── error/
│   │   ├── failure.dart                # Sealed Failure types (ServerFailure, CacheFailure, ValidationFailure, ...)
│   │   ├── exception.dart              # Custom exceptions thrown only within data layer
│   │   └── result.dart                 # Result<Failure, T> (Either-style) type + extensions
│   ├── usecase/
│   │   └── usecase.dart                # Abstract UseCase<Type, Params> base class(es)
│   ├── network/
│   │   ├── network_info.dart           # Connectivity abstraction
│   │   └── api_client.dart             # HTTP client abstraction (unused until Firebase/REST phase, defined now for contract stability)
│   ├── di/
│   │   └── injection_container.dart    # get_it instance + injectable init hook shared by both apps
│   ├── config/
│   │   ├── app_config.dart             # Environment-level config model
│   │   ├── tenant_config.dart          # Tenant/white-label config model
│   │   └── feature_flags.dart          # Feature flag model + evaluator
│   ├── logging/
│   │   └── app_logger.dart             # Logging abstraction (console now, Crashlytics-ready later)
│   ├── pagination/
│   │   └── paginated_result.dart       # Shared pagination envelope used by all list-returning repositories
│   ├── utils/
│   │   ├── validators.dart             # Shared form validators (email, phone, password strength)
│   │   ├── formatters.dart             # Currency/date/number formatting
│   │   └── extensions/                 # Dart/Flutter extension methods (BuildContext, String, DateTime, num)
│   └── constants/
│       └── app_constants.dart          # Non-tenant-specific constants (timeouts, page sizes, regex)
├── test/                                # Mirrors lib/ structure 1:1
└── pubspec.yaml                         # No dependency on any feature package or app (leaf of the dependency graph)
```

**Why this exists as its own package:** every feature depends on `core`; `core` depends on nothing else in the workspace. This makes the dependency direction unambiguous and prevents circular imports.

---

## 5. Design System Package Structure (`packages/design_system`)

```
packages/design_system/
├── lib/
│   ├── design_system.dart              # Barrel export
│   ├── tokens/
│   │   ├── app_colors.dart             # Semantic color tokens (resolved per tenant at runtime)
│   │   ├── app_typography.dart         # Text style tokens
│   │   ├── app_spacing.dart            # Spacing scale
│   │   ├── app_radii.dart              # Border-radius scale
│   │   └── app_breakpoints.dart        # Responsive breakpoints (mobile/tablet/desktop)
│   ├── theme/
│   │   ├── app_theme.dart              # ThemeData builder, consumes TenantConfig
│   │   └── theme_extensions.dart       # Custom ThemeExtension classes for tokens not covered by ThemeData
│   ├── components/
│   │   ├── buttons/
│   │   ├── cards/
│   │   ├── dialogs/
│   │   ├── bottom_sheets/
│   │   ├── inputs/                     # Text fields, search bars, dropdowns
│   │   ├── chips/                      # Filter chips, status badges
│   │   ├── states/                     # Loading, empty, error state widgets
│   │   ├── navigation/                 # App bars, bottom nav, side nav, tabs
│   │   ├── tables/                     # Admin data tables, pagination controls
│   │   ├── charts/                     # Analytics chart wrappers
│   │   └── feedback/                   # Snackbars/toasts, banners
│   └── layout/
│       └── responsive_layout_builder.dart
├── test/
└── pubspec.yaml                        # Depends only on core
```

Full component inventory is specified in `08_COMPONENT_LIBRARY.md`; this section only fixes **where** those components live.

---

## 6. Feature Package Structure (Feature-First, Clean Architecture)

Every entry under `packages/features/<feature_name>` follows this **identical internal skeleton**. This uniformity is mandatory — see `06_DEVELOPMENT_RULES.md`.

```
packages/features/<feature_name>/
├── lib/
│   ├── <feature_name>.dart                     # Barrel export (public API of the package)
│   ├── src/
│   │   ├── domain/
│   │   │   ├── entities/                       # Pure Dart, immutable, no dependency on data/presentation
│   │   │   ├── repositories/                   # Abstract repository interfaces
│   │   │   ├── usecases/                       # One class per use case (single `call()` method)
│   │   │   └── failures/                       # Feature-specific Failure subtypes (extends core Failure)
│   │   ├── data/
│   │   │   ├── models/                         # DTOs (freezed + json_serializable), map to/from entities
│   │   │   ├── datasources/
│   │   │   │   ├── <feature>_remote_data_source.dart   # Interface + Firebase impl (added, unused until backend phase)
│   │   │   │   └── <feature>_mock_data_source.dart     # Interface + in-memory/mock impl (active in Phase 1)
│   │   │   ├── mock/
│   │   │   │   └── <feature>_mock_fixtures.dart # Static/seeded mock data used by the mock data source
│   │   │   └── repositories/
│   │   │       └── <feature>_repository_impl.dart # Implements domain interface, delegates to data source
│   │   ├── presentation/
│   │   │   ├── bloc/                           # One bloc/cubit per screen or cohesive UI concern
│   │   │   │   └── <name>_bloc.dart / _event.dart / _state.dart
│   │   │   ├── screens/                        # Full-page widgets (routed destinations)
│   │   │   ├── widgets/                        # Feature-local widgets, not promoted to design_system
│   │   │   └── routing/
│   │   │       └── <feature>_routes.dart       # go_router `RouteBase` list for this feature
│   │   └── injection/
│   │       └── <feature>_injection_module.dart # @module injectable registrations for this feature
├── test/
│   ├── domain/
│   ├── data/
│   └── presentation/
└── pubspec.yaml                                 # Depends on core, design_system; NEVER on another feature package directly
```

**Key structural rules (enforced, see doc 06):**

- `domain/` has zero imports from `data/` or `presentation/`. It is pure business logic and contracts.
- `data/` depends only on `domain/` (to implement its interfaces) and `core`.
- `presentation/` depends on `domain/` (entities, use cases) — **never directly on `data/`**. Screens/blocs never import a `*RepositoryImpl` or a data source; they only see abstract repository interfaces via injected use cases.
- Cross-feature communication happens only through: (a) shared entities re-exported from `core` when truly universal (e.g., `Money`, `Address`), or (b) explicit use cases exposed via a feature's barrel file. Never via reaching into another feature's `src/`.
- `src/` is not exported directly; only the top-level barrel file (`<feature_name>.dart`) is public, enforced by Dart's `src/` convention plus `export` review.

---

## 7. Assets Organization

```
assets/
├── images/
│   ├── branding/              # Default/tenant-neutral logo, splash, placeholders
│   ├── illustrations/         # Empty-state, error-state, onboarding illustrations
│   └── placeholders/          # Product/avatar placeholders used by mock data
├── icons/
│   └── custom/                # Any icons not covered by an icon font/Material icons
├── fonts/
│   └── <font-family>/         # Bundled font files, declared in design_system pubspec
├── lottie/                    # Loading/success/empty animations
└── config/
    └── tenants/                # Per-tenant static asset manifests (see doc 11) — logo/color JSON referencing hosted or bundled assets
```

Assets are declared in `packages/design_system/pubspec.yaml` (not per-app) so both apps reference the same default asset catalog; tenant-specific overrides are resolved at runtime through `TenantConfig` (remote URLs or flavor-specific asset variants), not by duplicating the `assets/` tree per client.

## 8. Configuration Organization

```
config/
├── env/
│   ├── dev.env
│   ├── staging.env
│   └── prod.env
├── flavors/
│   ├── storefront_dev.json
│   ├── storefront_staging.json
│   ├── storefront_prod.json
│   ├── admin_dev.json
│   ├── admin_staging.json
│   └── admin_prod.json
├── tenants/
│   ├── default_tenant.json     # Baseline tenant used in Phase 1 development
│   └── <client_tenant>.json    # One file per onboarded enterprise client
└── firebase/
    ├── dev/                    # google-services.json / GoogleService-Info.plist / firebase_options.dart (added later, empty placeholders now)
    ├── staging/
    └── prod/
```

Full explanation of each file's contents and lifecycle is in `11_ENVIRONMENT_CONFIGURATION.md`. This section only fixes location.

## 9. Documentation Organization

```
docs/
├── 01_IMPLEMENTATION_PLAN.md
├── 02_PROJECT_STRUCTURE.md
├── 03_DEVELOPMENT_PHASES.md
├── 04_FEATURE_IMPLEMENTATION_ORDER.md
├── 05_ARCHITECTURE_GUIDELINES.md
├── 06_DEVELOPMENT_RULES.md
├── 07_SCREEN_CATALOG.md
├── 08_COMPONENT_LIBRARY.md
├── 09_ROUTING_PLAN.md
├── 10_DATA_FLOW.md
├── 11_ENVIRONMENT_CONFIGURATION.md
├── 12_MANUAL_TEST_PLAN.md
├── 13_CLIENT_DELIVERY_CHECKLIST.md
├── 14_IMPLEMENTATION_PROGRESS.md
└── adr/                          # Architecture Decision Records for any deviation from this plan, numbered ADR-0001, ADR-0002...
```

Any decision that changes something fixed in `01`–`11` after development starts must be captured as a new file in `docs/adr/` and cross-referenced from the affected document — the numbered docs are not silently edited without a trace.

---

## 10. Naming Conventions

| Item | Convention | Example |
|---|---|---|
| Package/folder names | `snake_case`, singular for infra, singular business noun for features | `packages/features/wishlist` |
| Dart file names | `snake_case.dart` | `product_detail_bloc.dart` |
| Class names | `UpperCamelCase` | `ProductDetailBloc` |
| Bloc files | `<name>_bloc.dart`, `<name>_event.dart`, `<name>_state.dart` | `cart_bloc.dart` |
| Cubit files | `<name>_cubit.dart`, `<name>_state.dart` | `wishlist_cubit.dart` |
| Use case classes | `VerbNoun` naming, one responsibility | `GetProductDetail`, `AddToCart`, `PlaceOrder` |
| Repository interfaces | `<Feature>Repository` (abstract) | `ProductRepository` |
| Repository implementations | `Mock<Feature>RepositoryImpl`, `Firebase<Feature>RepositoryImpl` | `MockProductRepositoryImpl` |
| Data sources | `<Feature>RemoteDataSource` (interface), `Mock<Feature>DataSource`, `Firebase<Feature>DataSource` | `MockProductDataSource` |
| DTO/model classes | `<Entity>Model` | `ProductModel` |
| Domain entity classes | `<Noun>` (no suffix) | `Product` |
| Screens | `<Name>Screen` | `ProductDetailScreen` |
| Feature-local widgets | `<Name>Widget` or descriptive noun, no generic `Widget1` names | `ProductRatingSummary` |
| Design-system components | `App<Component>` prefix to disambiguate from Flutter/Material widgets | `AppButton`, `AppCard`, `AppTextField` |
| Route path constants | `snake-case` URL paths, named constants in `<feature>_routes.dart` | `/products/:productId` |
| Route name constants | `UpperCamelCase` + `Route` suffix in code, referenced by `go_router` `name:` | `ProductDetailRoute` |
| Injectable modules | `<Feature>InjectionModule` | `CartInjectionModule` |
| Test files | Mirror source file name with `_test.dart` suffix | `product_detail_bloc_test.dart` |
| Environment files | `<env>.env`, lowercase | `staging.env` |
| Tenant config files | `<tenant_slug>_tenant.json` | `acme_tenant.json` |

## 11. Feature Organization Principles

1. **One feature = one package = one bounded context.** If a concept needs to be shared (e.g., `Address` used by both `checkout` and `profile`), promote it to `packages/core/lib/shared_entities/` (a designated subfolder for cross-feature entities) rather than importing one feature from another.
2. **Screens map 1:1 to routes.** Every top-level screen in `07_SCREEN_CATALOG.md` has exactly one corresponding file in some feature's `presentation/screens/`.
3. **Admin features are still features.** Admin-only concerns (`admin_dashboard`, `admin_catalog`, `admin_inventory`, `admin_orders`, `admin_customers`, `marketing`, `analytics_reports`, `tenant_management`) follow the exact same skeleton as customer features — no special-casing.
4. **Shared customer/admin concepts reuse domain, not presentation.** E.g., `Product` entity and `ProductRepository` interface are defined once (in `products` feature's domain layer) and consumed by both the customer `products` presentation and the admin `admin_catalog` presentation via the use case layer — `admin_catalog` depends on `products`'s domain (allowed: domain-to-domain dependency across features is permitted **only** when explicitly documented in `04_FEATURE_IMPLEMENTATION_ORDER.md`'s "Dependencies" field; UI never crosses).

## 12. Core Modules vs Shared Modules — Definitions

- **Core module (`packages/core`):** Technical infrastructure with no business meaning — error handling, DI wiring, networking, logging, config, formatting/validation utilities. Would exist even if this were not a commerce app.
- **Shared modules (`packages/design_system`, and `core/shared_entities`):** Cross-feature building blocks with **some** product meaning but no single feature ownership — visual components, and universally-shared entities like `Money`, `Address`, `PaginatedResult<T>`.
- **Feature modules (`packages/features/*`):** Business-meaningful, independently ownable slices — everything else.

This three-way split is what keeps the dependency graph acyclic: `features/* → design_system → core` and `features/* → core`, never the reverse, and never `feature A → feature B`'s internals.

---

## 13. Dependency Graph (Textual)

```
apps/storefront ──┐
apps/admin ────────┼──> packages/features/* ──> packages/design_system ──> packages/core
                   │                         └─────────────────────────────> packages/core
                   └──> packages/design_system, packages/core (for app-shell chrome)
```

No arrow ever points right-to-left. This is verified manually at every milestone review (see `06_DEVELOPMENT_RULES.md`) and is a Definition-of-Done item in `03_DEVELOPMENT_PHASES.md`.
