# 11 — Environment Configuration

**Status:** Planning document. Defines environments, flavors, secrets handling, app configuration, feature flags, and developer mode — the operational backbone that lets the same codebase serve every client and every deployment stage safely.

---

## 1. Environments

Three environments, each fully independent in configuration and (eventually) backend project:

| Environment | Purpose | `dataSourceMode` | Logging | Developer Mode | Firebase Project |
|---|---|---|---|---|---|
| `dev` | Local development, feature branches | `mock` (always) | verbose (console) | enabled | `wlcp-dev` (provisioned later, unused in Phase 1) |
| `staging` | Internal QA, client demos, pilot tenant UAT | `mock` (Phase 1 scope); architecturally capable of `firebase` once that project phase begins | info+ (console, remote sink later) | enabled | `wlcp-staging` (provisioned later) |
| `prod` | Client production release | `mock` (Phase 1 scope; becomes `firebase` post-integration) | warning+ (remote sink only) | **disabled** | `wlcp-prod-<tenant>` (provisioned later, one per tenant or shared multi-tenant project — decision deferred to backend-integration scoping) |

## 2. Flavors

Each environment maps to a Flutter flavor, per app, with its own entry point per `02_PROJECT_STRUCTURE.md` §3:

| App | Flavor | Entry Point | Bundle ID / App ID Suffix (mobile) | Web Build Output |
|---|---|---|---|---|
| Storefront | dev | `main_dev.dart` | `.dev` | `build/web-storefront-dev` |
| Storefront | staging | `main_staging.dart` | `.staging` | `build/web-storefront-staging` |
| Storefront | prod | `main_prod.dart` | *(none — production id)* | `build/web-storefront-prod` |
| Admin | dev | `main_dev.dart` | `.admin.dev` | `build/web-admin-dev` |
| Admin | staging | `main_staging.dart` | `.admin.staging` | `build/web-admin-staging` |
| Admin | prod | `main_prod.dart` | `.admin` | `build/web-admin-prod` |

Each `main_<flavor>.dart` does exactly three things: (1) set `AppConfig.environment`, (2) call `bootstrap(tenantId: ..., environment: ...)`, (3) `runApp(...)`. All actual startup sequencing (DI init, error zone, config load) lives in the shared `bootstrap.dart`, per the rule in `02_PROJECT_STRUCTURE.md` §3 that flavor entry points stay trivial.

## 3. Environment Variables

Stored in `config/env/<env>.env`, loaded at build time (via `--dart-define-from-file` or an equivalent compile-time injection mechanism — chosen at Phase 1 kickoff and recorded as an ADR if it deviates from this default):

| Variable | Example (dev) | Purpose |
|---|---|---|
| `ENVIRONMENT` | `dev` | Selects `AppConfig` environment branch |
| `DATA_SOURCE_MODE` | `mock` | `mock` \| `firebase` |
| `LOG_LEVEL` | `debug` | Minimum log level emitted |
| `MOCK_LATENCY_MIN_MS` / `MOCK_LATENCY_MAX_MS` | `300` / `800` | Simulated network delay range for mock data sources |
| `DEFAULT_TENANT_ID` | `default` | Which `config/tenants/*.json` file loads at bootstrap when no runtime tenant selector overrides it |
| `ENABLE_DEVELOPER_MODE` | `true` | Gates Developer Panel + Tenant Switcher route registration |
| `SENTRY_DSN` / crash-reporting key | *(empty in dev)* | Present but inert until the backend/observability integration phase |

**Rule:** No environment variable is ever read directly (`String.fromEnvironment`) from feature code — every value is funneled through the single `AppConfig` object constructed once at bootstrap, so feature code has exactly one configuration seam to depend on (mirrors the Repository Pattern's single-seam philosophy).

## 4. Secrets

- **Phase 1 scope has no real secrets** (no live API keys, no real payment credentials, no real Firebase credentials in active use). This section defines the handling policy so it's correct by construction once real secrets exist.
- Real secrets (Firebase config files, future payment gateway keys) are never committed to the repository. `config/firebase/<env>/` is `.gitignore`d except for placeholder/example files (`firebase_options.example.dart`).
- Secret injection for CI/CD (once set up) uses the CI platform's encrypted secret store, written to the expected file paths at build time — never baked into source.
- `.env` files under `config/env/` contain **non-secret** configuration only (feature flags, log levels, mock tuning); anything secret is explicitly named `*.secret.env` and excluded from version control, with a checked-in `*.secret.env.example` template.

## 5. App Config (`AppConfig`)

Immutable, constructed once at bootstrap from environment variables + compiled flavor constants:

```dart
class AppConfig {
  final Environment environment; // dev | staging | prod
  final DataSourceMode dataSourceMode; // mock | firebase
  final LogLevel logLevel;
  final Duration mockLatencyMin;
  final Duration mockLatencyMax;
  final bool isDeveloperModeAvailable;
  final bool storefrontMaintenanceMode;
  final bool adminMaintenanceMode;
}
```

Consumed by: DI bootstrap (selects mock vs. Firebase bindings), `AppLogger` (level filtering), Router (developer-panel route registration, maintenance redirect), Mock data sources (latency simulation).

## 6. Tenant Config (`TenantConfig`)

Loaded once at bootstrap based on `DEFAULT_TENANT_ID` (Phase 1) or a runtime tenant resolution strategy (future: subdomain-based or login-time-resolved for a true multi-tenant SaaS deployment — flagged as a future expansion, not Phase 1 scope, since Phase 1 targets one active tenant per running app instance, with the Tenant Switcher (DEV) providing manual switching for demo purposes only).

```dart
class TenantConfig {
  final String tenantId;
  final String displayName;
  final BrandingTokens branding;      // colors, logo, font family ref
  final CopyOverrides copy;           // key -> localized string map
  final FeatureFlagSet featureFlags;
  final String defaultLocale;
  final String supportEmail;
  final bool allowGuestBrowsing;
  final bool allowGuestCart;
}
```

Stored as JSON under `config/tenants/<tenant_slug>_tenant.json` (Phase 1: file-based; future: Firestore-backed `tenants/{tenantId}` document per `10_DATA_FLOW.md` §7, loaded through the same `TenantConfigRepository` interface so this is another Mock→Firebase swap, not a redesign).

## 7. Feature Flags

- Implemented as `FeatureFlagSet` (`Map<FeatureFlag, bool>` with a typed enum, not raw strings) inside `TenantConfig`, evaluated through a single `FeatureFlagService.isEnabled(FeatureFlag flag)` call site pattern.
- Baseline flags (Phase 1): `wishlist`, `reviews`, `promotions`, `guestCheckout`, `notifications`, `support`, `multiplePaymentMethods`, `productVariants`. Each maps to a route-registration and nav-entry check per `06_DEVELOPMENT_RULES.md` Rule 39.
- Flags are additive-only within a released version — removing a flag entirely (rather than defaulting it permanently on/off) requires an ADR, since it's a breaking change to `TenantConfig` schema.
- Admin-side management via the Feature Flag Manager screen (`07_SCREEN_CATALOG.md` §T), SuperAdmin-only.

## 8. Developer Mode

- Gated entirely by `AppConfig.isDeveloperModeAvailable`, which is hardcoded `false` at compile time for the `prod` flavor's `main_prod.dart` (not just environment-variable-controlled) — this is a defense-in-depth measure so a misconfigured environment variable cannot accidentally ship developer tooling to production.
- When enabled, unlocks: Developer Panel route/menu entry, Tenant Switcher route/menu entry, verbose logging, mock-latency override controls, mock-failure-injection controls.
- Manual test plan (`12_MANUAL_TEST_PLAN.md`) includes an explicit check that developer-mode surfaces are absent from a `prod`-flavor release build.

## 9. Firebase Configuration (Structural Readiness Only)

Not wired to live calls in this plan's scope, but the structure is fixed so the later integration phase has a clear destination:

```
config/firebase/
├── dev/       firebase_options.dart, google-services.json, GoogleService-Info.plist
├── staging/   (same file set)
└── prod/      (same file set)
```

- One Firebase project per environment at minimum; whether production is single-project-multi-tenant (Firestore `tenants/{tenantId}` partitioning, per `10_DATA_FLOW.md` §7) or project-per-enterprise-client is a decision explicitly deferred to the backend-integration project's own scoping document — this plan only guarantees the frontend repository-interface layer is agnostic to that choice.
- `firebase_options.dart` per environment is generated via the FlutterFire CLI once real projects exist; until then, a placeholder file with an `UnimplementedError`-throwing `DefaultFirebaseOptions.currentPlatform` keeps the dependency compiling without requiring real credentials during Phase 1 development.

## 10. Configuration Loading Sequence (Bootstrap)

```
main_<flavor>.dart
  → bootstrap(environment, tenantId)
      1. Load AppConfig from compiled flavor constants + env vars
      2. Load TenantConfig from config/tenants/<tenantId>_tenant.json (bundled asset in Phase 1)
      3. Initialize AppLogger with AppConfig.logLevel
      4. Initialize DI container (get_it + injectable), binding Mock or Firebase
         implementations per AppConfig.dataSourceMode
      5. Register each feature's InjectionModule
      6. Build AppTheme from TenantConfig.branding
      7. runApp(AppWidget(config, tenantConfig))
```

This sequence is identical for both apps; only which feature modules are registered in step 5 differs (customer feature set vs. admin feature set), per `02_PROJECT_STRUCTURE.md` §3.

## 11. Environment/Tenant Matrix Example

| Scenario | Environment | Tenant | Data Source | Developer Mode |
|---|---|---|---|---|
| Engineer building a new feature locally | dev | `default` | mock | on |
| QA regression pass before a client demo | staging | `default` or a client-specific demo tenant | mock | on |
| Client UAT sign-off | staging | `<client>_tenant.json` | mock | on (used to reset data between UAT sessions) |
| Production release to Client A | prod | `<clientA>_tenant.json` | mock (Phase 1) → firebase (post-integration) | off |
| Production release to Client B (second enterprise client, proving white-label) | prod | `<clientB>_tenant.json` | mock (Phase 1) → firebase (post-integration) | off |

This matrix is the operational proof that the same build artifact (per flavor) serves every client via configuration alone, directly satisfying `01_IMPLEMENTATION_PLAN.md` Success Criterion 5.
