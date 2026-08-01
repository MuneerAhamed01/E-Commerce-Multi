# 03 — Development Phases

**Status:** Planning document. Defines the complete phase-by-phase, milestone-by-milestone execution plan.

---

## How to Read This Document

- The project is broken into **29 phases**, executed strictly in order (a phase does not start until all its dependency phases are 🟩 Completed in `14_IMPLEMENTATION_PROGRESS.md`).
- Each phase is broken into **milestones of 2–6 hours**. A milestone is the smallest unit of independently reviewable, always-runnable work.
- Every milestone in this document must satisfy both:
  1. The **Phase-Level Review Checklist** (applies to every milestone within that phase), and
  2. Its own **Milestone-Specific Notes** column (anything beyond the generic checklist).
- **Universal Definition of Done**, applying to every single milestone in the entire project, without exception:
  - [ ] Code compiles for every affected app/package with zero analyzer errors or warnings.
  - [ ] `apps/storefront` and `apps/admin` still build and run after the milestone (whichever apps are affected).
  - [ ] No cross-feature or cross-layer import violations introduced (see `06_DEVELOPMENT_RULES.md`).
  - [ ] Unit tests exist for any new domain/data logic; widget tests exist for any new non-trivial widget/bloc.
  - [ ] Loading / empty / error states implemented for any new screen touching async data.
  - [ ] `14_IMPLEMENTATION_PROGRESS.md` updated: milestone moved to 🟩 Completed with date and short note.
  - [ ] No TODO left unresolved without a tracked follow-up milestone.

---

## Phase 1 — Project Foundation

**Purpose:** Stand up the monorepo, tooling, and both app shells so every later phase has a place to put code.

**Deliverables:** Melos workspace; `analysis_options.yaml`; empty `apps/storefront` and `apps/admin` Flutter projects with flavor entry-point stubs; root scripts for bootstrap/analyze/test/format.

**Dependencies:** None (first phase).

**Completion Criteria:** `melos bootstrap` succeeds; both apps launch to a placeholder screen on at least one platform each; `melos run analyze` and `melos run test` run clean (even if trivial).

**Estimated Complexity:** Medium (low technical difficulty, high importance — mistakes here ripple everywhere).

**Estimated Development Time:** 10–16 hours (4 milestones).

**Risks:** Wrong Flutter/Dart SDK pin causes churn later; inconsistent lint config across packages if not centralized immediately.

**Phase-Level Review Checklist:** Melos config valid; lint baseline applied to every package via `include:`; both apps run on at least one target platform; folder names match `02_PROJECT_STRUCTURE.md` exactly.

| # | Milestone | Objective | Deliverables | Files/Folders Affected | Dependencies | Risk | Est. Time |
|---|---|---|---|---|---|---|---|
| 1.1 | Monorepo & Melos setup | Initialize workspace and package globs | `melos.yaml`, root `pubspec.yaml` (workspace), package stub folders | `/`, `packages/*` (empty stubs) | None | Low | 2–3h |
| 1.2 | Lint & format baseline | One shared analyzer config for all packages | `analysis_options.yaml`, `tool/format.sh`/`tool/analyze.sh` | `/analysis_options.yaml`, `tool/` | 1.1 | Low | 2–3h |
| 1.3 | App shell scaffolding | Create both Flutter apps with flavor entry stubs | `apps/storefront/lib/main_*.dart`, `apps/admin/lib/main_*.dart`, platform runners | `apps/storefront/`, `apps/admin/` | 1.1 | Medium (platform tooling quirks) | 3–6h |
| 1.4 | Root docs & CI-ready scripts | Wire root README, melos scripts for CI later | `README.md`, `melos.yaml` scripts section | `/README.md`, `melos.yaml` | 1.1–1.3 | Low | 2–3h |

---

## Phase 2 — Core Architecture

**Purpose:** Build the technical foundation every feature depends on: error handling, use case contracts, DI bootstrap, logging.

**Deliverables:** `packages/core` fully scaffolded per `02_PROJECT_STRUCTURE.md` §4, with working `Result`/`Failure` types, `UseCase` base classes, `get_it`/`injectable` bootstrap, shared entities.

**Dependencies:** Phase 1.

**Completion Criteria:** `packages/core` compiles, has unit tests for `Result`/`Failure`/formatters/validators, and is consumable by a throwaway test feature.

**Estimated Complexity:** High (gets contracts right once, for everyone).

**Estimated Development Time:** 14–20 hours (5 milestones).

**Risks:** Over- or under-designing the `Result`/`Failure` hierarchy; getting this wrong forces edits across every feature later.

**Phase-Level Review Checklist:** `core` has zero dependency on any feature or app; every public class documented; 100% of `core` logic unit-tested.

| # | Milestone | Objective | Deliverables | Files/Folders Affected | Dependencies | Risk | Est. Time |
|---|---|---|---|---|---|---|---|
| 2.1 | Error handling & Result type | Establish functional error handling contract | `error/failure.dart`, `error/exception.dart`, `error/result.dart` | `packages/core/lib/error/` | 1.x | Medium | 3–4h |
| 2.2 | UseCase base & pagination | Standard shape for all use cases and list results | `usecase/usecase.dart`, `pagination/paginated_result.dart` | `packages/core/lib/usecase/`, `pagination/` | 2.1 | Low | 2–3h |
| 2.3 | DI bootstrap | Shared `get_it` + `injectable` init hook | `di/injection_container.dart` | `packages/core/lib/di/` | 2.1 | Medium (codegen setup) | 3–4h |
| 2.4 | Logging & network_info | Cross-cutting logging + connectivity abstraction | `logging/app_logger.dart`, `network/network_info.dart`, `network/api_client.dart` (contract only) | `packages/core/lib/logging/`, `network/` | 2.1 | Low | 2–3h |
| 2.5 | Shared entities & utils | `Money`, `Address`, validators, formatters | `shared_entities/`, `utils/validators.dart`, `utils/formatters.dart` | `packages/core/lib/` | 2.1 | Low | 3–4h |

---

## Phase 3 — Environment & Configuration

**Purpose:** Make the app tenant-aware and environment-aware from the first runnable build.

**Deliverables:** `AppConfig`, `TenantConfig`, `FeatureFlags` models; default tenant JSON; flavor wiring in both apps' `bootstrap.dart`.

**Dependencies:** Phase 2.

**Completion Criteria:** Both apps boot with a `TenantConfig` loaded (default tenant), print resolved environment in debug console, and a feature flag can toggle a placeholder UI element.

**Estimated Complexity:** Medium-High (this is the seam multi-tenancy depends on — see `01_IMPLEMENTATION_PLAN.md` R3).

**Estimated Development Time:** 10–14 hours (4 milestones).

**Risks:** Designing `TenantConfig` too narrowly (e.g., colors only, forgetting copy/feature flags) forces rework once feature UIs exist.

**Phase-Level Review Checklist:** Config models are `freezed`/immutable; no widget reads `Platform`/`kDebugMode` directly for environment logic (must go through `AppConfig`); default tenant file validated against schema.

| # | Milestone | Objective | Deliverables | Files/Folders Affected | Dependencies | Risk | Est. Time |
|---|---|---|---|---|---|---|---|
| 3.1 | AppConfig & env loading | Load per-flavor config at startup | `core/config/app_config.dart`, `config/env/*.env` | `packages/core/lib/config/`, `config/env/` | 2.x | Medium | 3–4h |
| 3.2 | TenantConfig & default tenant | Model branding/copy/theme-token overrides | `core/config/tenant_config.dart`, `config/tenants/default_tenant.json` | `packages/core/lib/config/`, `config/tenants/` | 3.1 | High (schema must be forward-compatible) | 3–4h |
| 3.3 | Feature flag service | Runtime flag evaluation, tenant + env aware | `core/config/feature_flags.dart` | `packages/core/lib/config/` | 3.1–3.2 | Medium | 2–3h |
| 3.4 | Flavor wiring in both apps | Connect `main_*.dart` → `bootstrap.dart` → config load | `apps/*/lib/main_*.dart`, `apps/*/lib/bootstrap.dart` | `apps/storefront/`, `apps/admin/` | 3.1–3.3 | Low | 2–3h |

---

## Phase 4 — Design System & Shared Widgets

**Purpose:** Establish the visual language and reusable component library before any feature screen is built, so no feature reinvents UI primitives.

**Deliverables:** Full token set; `AppTheme` builder driven by `TenantConfig`; base component set per `08_COMPONENT_LIBRARY.md`.

**Dependencies:** Phase 3 (needs `TenantConfig` to drive theming).

**Completion Criteria:** A design-system gallery/showcase screen (internal, dev-only) renders every component in both light/dark and against two different mock tenant configs.

**Estimated Complexity:** Medium (broad but mechanical).

**Estimated Development Time:** 20–28 hours (6 milestones).

**Risks:** Components built ad hoc per feature later if this phase under-delivers coverage; must be genuinely complete before Phase 7 starts.

**Phase-Level Review Checklist:** Every component documented in `08_COMPONENT_LIBRARY.md` exists as code; no component hardcodes a color/spacing value outside the token set; components pass a11y contrast check.

| # | Milestone | Objective | Deliverables | Files/Folders Affected | Dependencies | Risk | Est. Time |
|---|---|---|---|---|---|---|---|
| 4.1 | Design tokens | Colors, typography, spacing, radii, breakpoints | `tokens/*.dart` | `packages/design_system/lib/tokens/` | 3.2 | Medium | 3–4h |
| 4.2 | Theme builder | `AppTheme` + `ThemeExtension`s from `TenantConfig` | `theme/app_theme.dart`, `theme/theme_extensions.dart` | `packages/design_system/lib/theme/` | 4.1 | Medium | 3–5h |
| 4.3 | Buttons, inputs, chips | Core interactive components | `components/buttons/`, `components/inputs/`, `components/chips/` | `packages/design_system/lib/components/` | 4.2 | Low | 3–5h |
| 4.4 | Cards, dialogs, bottom sheets | Container/overlay components | `components/cards/`, `components/dialogs/`, `components/bottom_sheets/` | same | 4.2 | Low | 3–5h |
| 4.5 | State & feedback widgets | Loading/empty/error + snackbar/toast/banner | `components/states/`, `components/feedback/` | same | 4.2 | Low | 3–4h |
| 4.6 | Navigation, tables, charts shells | App bars, nav, tabs, admin table/chart wrappers | `components/navigation/`, `components/tables/`, `components/charts/` | same | 4.2 | Medium (table/chart flexibility) | 4–6h |

---

## Phase 5 — Routing Foundation

**Purpose:** Establish the navigation skeleton for both apps before any feature routes are added.

**Deliverables:** `go_router` instances for both apps with shell routes, guard hooks, 404/error/maintenance routes.

**Dependencies:** Phase 3 (auth/role guard needs config), Phase 4 (shells need chrome components).

**Completion Criteria:** Both apps navigate between placeholder branches with working back/forward, deep-link resolution, and a working 404 page.

**Estimated Complexity:** Medium-High.

**Estimated Development Time:** 10–14 hours (4 milestones).

**Risks:** Guard logic duplicated per app instead of shared from `core`; nested shell misconfiguration breaking browser back button on Web.

**Phase-Level Review Checklist:** Route guard logic lives in `core`, imported by both routers; every branch has a named route constant; 404 and maintenance routes verified.

| # | Milestone | Objective | Deliverables | Files/Folders Affected | Dependencies | Risk | Est. Time |
|---|---|---|---|---|---|---|---|
| 5.1 | Storefront router skeleton | Shell + public/auth branches | `apps/storefront/lib/app/app_router.dart` | `apps/storefront/lib/app/` | 4.6 | Medium | 3–4h |
| 5.2 | Admin router skeleton | Shell + RBAC branch stub | `apps/admin/lib/app/app_router.dart` | `apps/admin/lib/app/` | 4.6 | Medium | 3–4h |
| 5.3 | Shared guard utilities | Auth guard, role guard, redirect logic | `core/routing/route_guard.dart` (new subfolder in core) | `packages/core/lib/routing/` | 3.3, 5.1–5.2 | Medium | 2–3h |
| 5.4 | 404 / error / maintenance routes | Fallback UX for bad routes and maintenance mode | Shared widgets + router `errorBuilder` wiring | `packages/design_system/`, both `app_router.dart` | 5.1–5.3 | Low | 2–3h |

---

## Phase 6 — Mock Data Infrastructure

**Purpose:** Define one consistent pattern for mock data so every subsequent feature reuses it instead of inventing its own.

**Deliverables:** Mock data source pattern/template, shared seed data set, developer panel scaffold.

**Dependencies:** Phase 2 (Result/UseCase), Phase 3 (feature flags for dev panel visibility).

**Completion Criteria:** A reference "ping" feature (throwaway or documented as the canonical example) demonstrates domain → mock data source → repository → use case → bloc → screen end to end.

**Estimated Complexity:** Medium.

**Estimated Development Time:** 8–12 hours (3 milestones).

**Risks:** If the mock pattern doesn't mirror realistic async/paginated/Firestore-shaped data, Phase-26+ backend integration gets harder (see `01_IMPLEMENTATION_PLAN.md` R2).

**Phase-Level Review Checklist:** Mock data sources simulate latency and failure cases (not just happy path); fixtures are realistic in volume (dozens of products, not 3).

| # | Milestone | Objective | Deliverables | Files/Folders Affected | Dependencies | Risk | Est. Time |
|---|---|---|---|---|---|---|---|
| 6.1 | Mock data source pattern | Canonical template + latency/failure simulation | Documented pattern + reference implementation | `packages/core/lib/` (shared mock utils), one reference feature | 2.x, 5.x | Medium | 3–4h |
| 6.2 | Shared seed data set | Cross-feature consistent fixtures (users, products, categories, orders) | Fixture data files | `packages/features/*/lib/src/data/mock/` (seed source of truth referenced across features) | 6.1 | Medium | 3–5h |
| 6.3 | Developer panel scaffold | Dev-only screen: reset mock data, switch env/tenant | Dev panel screen + entry point | New minimal feature or `apps/*/lib` dev tools | 3.3, 6.1 | Low | 2–3h |

---

## Phase 7 — Authentication

**Purpose:** Deliver the full auth journey; unlocks every session-gated feature after it.

**Deliverables:** Login, register, forgot password, OTP verification, splash/onboarding, session persistence, auth guard wired live.

**Dependencies:** Phases 1–6.

**Completion Criteria:** A user can register, log out, log back in, recover a password (mock OTP), and session persists across app restarts (mocked local persistence).

**Estimated Complexity:** High.

**Estimated Development Time:** 22–30 hours (6 milestones).

**Risks:** Session persistence design chosen here is reused by every later "am I logged in" check — must be robust.

**Phase-Level Review Checklist:** All forms validated (see `06_DEVELOPMENT_RULES.md`); loading/empty/error states present; guard redirects unauthenticated users from any protected route.

| # | Milestone | Objective | Deliverables | Files/Folders Affected | Dependencies | Risk | Est. Time |
|---|---|---|---|---|---|---|---|
| 7.1 | Auth domain layer | Entities, repository interface, use cases | `features/authentication/lib/src/domain/` | new | 2.x | Medium | 3–4h |
| 7.2 | Auth data layer (mock) | Mock data source, fixtures, repository impl | `features/authentication/lib/src/data/` | 7.1, 6.1 | Medium | 3–5h |
| 7.3 | Splash & onboarding | First-run experience, tenant-branded splash | `features/authentication/lib/src/presentation/screens/` | 7.1–7.2, 4.x | Low | 2–4h |
| 7.4 | Login & register | Core auth screens/bloc | same | 7.1–7.2 | Medium | 4–6h |
| 7.5 | Forgot password & OTP | Recovery flow screens/bloc | same | 7.1–7.2 | Medium | 3–5h |
| 7.6 | Session + guard integration | Wire persistence + live guard behavior | `core/routing/route_guard.dart`, `app_router.dart` (both apps) | 5.3, 7.1–7.5 | High (security-relevant) | 3–5h |

---

## Phase 8 — Dashboard / Home

**Purpose:** Give both apps a real landing experience post-login.

**Deliverables:** Storefront Home (banners, featured products/categories); Admin Dashboard shell (KPI placeholders wired to mock aggregation).

**Dependencies:** Phase 7 (session), Phase 4 (components).

**Completion Criteria:** Authenticated users land on a populated home/dashboard screen with working navigation to at least one downstream feature stub.

**Estimated Complexity:** Medium.

**Estimated Development Time:** 12–18 hours (4 milestones).

**Phase-Level Review Checklist:** Home/dashboard screens have loading/empty/error states; layout responsive across breakpoints.

| # | Milestone | Objective | Deliverables | Files/Folders Affected | Dependencies | Risk | Est. Time |
|---|---|---|---|---|---|---|---|
| 8.1 | Storefront home domain/data | Aggregation use case for banners/featured items | `features/dashboard/lib/src/domain/`, `data/` | 7.x | Low | 3–4h |
| 8.2 | Storefront home presentation | Home screen/bloc/widgets | `features/dashboard/lib/src/presentation/` | 8.1 | Medium | 4–6h |
| 8.3 | Admin dashboard domain/data | KPI aggregation use case, mock stats | `features/admin_dashboard/lib/src/domain/`, `data/` | 7.x | Low | 3–4h |
| 8.4 | Admin dashboard presentation | Dashboard screen/bloc/widgets | `features/admin_dashboard/lib/src/presentation/` | 8.3 | Medium | 3–5h |

---

## Phase 9 — Products

**Purpose:** Core catalog browsing and detail experience — the heart of the storefront.

**Deliverables:** Product listing, product detail (variants, gallery), reviews.

**Dependencies:** Phase 8.

**Completion Criteria:** User can browse a paginated product list, open a detail page, select a variant, and submit a mock review.

**Estimated Complexity:** High.

**Estimated Development Time:** 22–30 hours (5 milestones).

**Phase-Level Review Checklist:** Pagination works with mock latency; variant selection updates price/stock/imagery correctly; empty/error states for zero results and simulated failures.

| # | Milestone | Objective | Deliverables | Files/Folders Affected | Dependencies | Risk | Est. Time |
|---|---|---|---|---|---|---|---|
| 9.1 | Products domain layer | Entities (Product, Variant, Review), repository, use cases | `features/products/lib/src/domain/` | 6.x, 8.x | Medium | 4–5h |
| 9.2 | Products data layer (mock) | Mock data source + fixtures + repository impl | `features/products/lib/src/data/` | 9.1 | Medium | 4–6h |
| 9.3 | Product listing | Screen/bloc, `ProductCard`, pagination | `features/products/lib/src/presentation/` | 9.1–9.2, 4.x | Medium | 5–6h |
| 9.4 | Product detail | Screen/bloc, gallery, variant selector | same | 9.1–9.2 | High (variant/price/stock interplay) | 5–6h |
| 9.5 | Reviews | Review list + submission form | same | 9.1–9.2 | Low | 3–4h |

---

## Phase 10 — Categories

**Purpose:** Structured browsing entry point into the catalog.

**Deliverables:** Category browse (grid/tree) and category detail (filtered product list).

**Dependencies:** Phase 9.

**Completion Criteria:** User can drill from top-level categories to a filtered product list reusing the Products listing UI.

**Estimated Complexity:** Medium.

**Estimated Development Time:** 8–12 hours (2 milestones).

**Phase-Level Review Checklist:** Category hierarchy renders correctly to arbitrary depth; deep link to a category resolves directly.

| # | Milestone | Objective | Deliverables | Files/Folders Affected | Dependencies | Risk | Est. Time |
|---|---|---|---|---|---|---|---|
| 10.1 | Categories domain/data | Entity, tree structure, repository, use cases | `features/categories/lib/src/domain/`, `data/` | 9.1 | Medium | 4–5h |
| 10.2 | Categories presentation | Browse + detail screens/bloc | `features/categories/lib/src/presentation/` | 10.1, 9.3 (reuse listing) | Medium | 4–7h |

---

## Phase 11 — Search

**Purpose:** Fast product discovery via query, filters, and sort.

**Deliverables:** Search bar with suggestions/recent searches, results screen, filter/sort bottom sheet.

**Dependencies:** Phase 9, Phase 10.

**Completion Criteria:** User can search, apply filters and sort, and see results update, including a "no results" empty state.

**Estimated Complexity:** Medium-High.

**Estimated Development Time:** 12–16 hours (3 milestones).

**Phase-Level Review Checklist:** Debounced search input; filters compose correctly (AND semantics documented); recent searches persist locally.

| # | Milestone | Objective | Deliverables | Files/Folders Affected | Dependencies | Risk | Est. Time |
|---|---|---|---|---|---|---|---|
| 11.1 | Search domain/data | Query/filter/sort models, use cases | `features/search/lib/src/domain/`, `data/` | 9.1, 10.1 | Medium | 4–5h |
| 11.2 | Search entry & suggestions | Search bar, suggestions, recent/trending searches | `features/search/lib/src/presentation/` | 11.1 | Medium | 4–5h |
| 11.3 | Results, filters, sort | Results screen + filter/sort bottom sheet | same | 11.1–11.2 | Medium | 4–6h |

---

## Phase 12 — Wishlist

**Purpose:** Allow users to save products for later.

**Deliverables:** Wishlist domain/data, wishlist screen, save/remove toggle integrated into product cards/detail.

**Dependencies:** Phase 9.

**Completion Criteria:** Toggling wishlist state from listing/detail reflects instantly on the Wishlist screen and persists across session.

**Estimated Complexity:** Low-Medium.

**Estimated Development Time:** 6–10 hours (2 milestones).

**Phase-Level Review Checklist:** Wishlist state uses a single source of truth (Cubit) reflected consistently across all entry points.

| # | Milestone | Objective | Deliverables | Files/Folders Affected | Dependencies | Risk | Est. Time |
|---|---|---|---|---|---|---|---|
| 12.1 | Wishlist domain/data | Entity, repository, add/remove/get use cases | `features/wishlist/lib/src/domain/`, `data/` | 9.1 | Low | 3–4h |
| 12.2 | Wishlist presentation | Screen/cubit + cross-feature toggle widget | `features/wishlist/lib/src/presentation/`, integration point in `products` widgets | 12.1, 9.3–9.4 | Medium (cross-feature integration point) | 3–6h |

---

## Phase 13 — Cart

**Purpose:** Manage items intended for purchase, including pricing and promo codes.

**Deliverables:** Cart domain/data (pricing engine, promo code use case), cart screen/bloc, global cart badge.

**Dependencies:** Phase 9.

**Completion Criteria:** User can add/update/remove items, apply a valid/invalid promo code, and see accurate totals (subtotal, discount, tax placeholder, total).

**Estimated Complexity:** High (pricing correctness is business-critical).

**Estimated Development Time:** 14–20 hours (3 milestones).

**Phase-Level Review Checklist:** Pricing math unit-tested with edge cases (zero qty, max qty, invalid promo, stacked discounts policy documented); cart persists across app restart.

| # | Milestone | Objective | Deliverables | Files/Folders Affected | Dependencies | Risk | Est. Time |
|---|---|---|---|---|---|---|---|
| 13.1 | Cart domain/data | Entities, pricing calculation, promo use case | `features/cart/lib/src/domain/`, `data/` | 9.1 | High | 5–7h |
| 13.2 | Cart presentation | Screen/bloc, quantity controls, promo entry | `features/cart/lib/src/presentation/` | 13.1, 4.x | Medium | 5–7h |
| 13.3 | Global cart badge integration | Shell-level cart count indicator | `apps/storefront/lib/app/app_shell.dart` | 13.1–13.2 | Low | 2–3h |

---

## Phase 14 — Checkout

**Purpose:** Convert a cart into a placed order.

**Deliverables:** Address selection/entry, shipping + payment method selection, order review, confirmation.

**Dependencies:** Phase 13, Phase 16 (payment methods — see note below; payment **method selection UI** ships here, full Payments feature domain/data is Phase 16 but its minimal contract is needed earlier — see Milestone 14.3 dependency note).

**Completion Criteria:** User can complete an end-to-end mock checkout from cart to confirmation screen with an order created in mock Orders data.

**Estimated Complexity:** High (most business-rule-dense flow in the app).

**Estimated Development Time:** 20–28 hours (5 milestones).

**Phase-Level Review Checklist:** All steps validated before proceeding (no skipping required address/payment); back navigation preserves entered data; order total matches cart total at time of placement.

| # | Milestone | Objective | Deliverables | Files/Folders Affected | Dependencies | Risk | Est. Time |
|---|---|---|---|---|---|---|---|
| 14.1 | Checkout domain/data | Address, ShippingMethod, CheckoutSession entities/use cases | `features/checkout/lib/src/domain/`, `data/` | 13.1 | Medium | 4–6h |
| 14.2 | Address step | Select/add/edit address screen | `features/checkout/lib/src/presentation/` | 14.1 | Medium | 4–5h |
| 14.3 | Shipping & payment method step | Method selection screens (payment methods list sourced from a minimal `PaymentMethod` contract defined jointly with Phase 16.1) | same | 14.1–14.2 | Medium | 4–6h |
| 14.4 | Review & place order | Summary screen, place-order use case, mock order creation | same | 14.1–14.3, 15.1 (Orders domain must exist to create the order) | High | 4–6h |
| 14.5 | Confirmation | Success screen, receipt summary | same | 14.4 | Low | 2–3h |

> **Sequencing note:** Milestone 14.4 has a forward dependency on the Orders domain layer (15.1). In execution order, Milestone 15.1 (Orders domain/data contracts) is pulled forward and completed immediately before 14.4. This is the one intentional exception to strict phase ordering and must be reflected explicitly in `14_IMPLEMENTATION_PROGRESS.md` when scheduling.

---

## Phase 15 — Orders

**Purpose:** Let users track and manage placed orders.

**Deliverables:** Order history, order detail/tracking, cancel/return flow.

**Dependencies:** Phase 14 (shares domain contract, see sequencing note above).

**Completion Criteria:** Orders placed in checkout appear in history with correct status, and can be cancelled per policy (e.g., only while status = "Processing").

**Estimated Complexity:** Medium-High.

**Estimated Development Time:** 14–18 hours (4 milestones).

**Phase-Level Review Checklist:** Order status enum drives all UI state (no magic strings); tracking timeline renders chronologically.

| # | Milestone | Objective | Deliverables | Files/Folders Affected | Dependencies | Risk | Est. Time |
|---|---|---|---|---|---|---|---|
| 15.1 | Orders domain/data | Order, OrderStatus, OrderTracking entities/use cases | `features/orders/lib/src/domain/`, `data/` | 13.1 | Medium | 4–5h |
| 15.2 | Order history | List screen/bloc | `features/orders/lib/src/presentation/` | 15.1 | Low | 3–4h |
| 15.3 | Order detail & tracking | Detail screen with timeline | same | 15.1 | Medium | 4–5h |
| 15.4 | Cancel/return flow | Action flow + confirmation | same | 15.1–15.3 | Medium | 3–4h |

---

## Phase 16 — Payments

**Purpose:** Manage saved payment methods and define the payment gateway abstraction that later accepts a real provider.

**Deliverables:** PaymentMethod domain/data, mock gateway abstraction, saved methods screen, add-method form.

**Dependencies:** Phase 7 (profile-adjacent), feeds into Phase 14.3.

**Completion Criteria:** User can add/remove a mock payment method and select it during checkout.

**Estimated Complexity:** Medium (mock now, deliberately designed as an integration seam for later).

**Estimated Development Time:** 8–12 hours (2 milestones).

**Phase-Level Review Checklist:** `PaymentGateway` interface documented as the explicit seam for a future real provider (see `10_DATA_FLOW.md`); card data never logged in plaintext even in mock form.

| # | Milestone | Objective | Deliverables | Files/Folders Affected | Dependencies | Risk | Est. Time |
|---|---|---|---|---|---|---|---|
| 16.1 | Payments domain/data | PaymentMethod entity, PaymentGateway interface + mock impl | `features/payments/lib/src/domain/`, `data/` | 7.1 | Medium | 4–6h |
| 16.2 | Payments presentation | Saved methods list, add-method form | `features/payments/lib/src/presentation/` | 16.1 | Low | 4–6h |

---

## Phase 17 — Notifications

**Purpose:** Central place for order/marketing/system notifications; abstraction ready for real push later.

**Deliverables:** Notification domain/data, notification center screen, preferences screen.

**Dependencies:** Phase 15 (order-triggered notifications reference order data).

**Completion Criteria:** Mock notifications appear in a center with read/unread state; preferences toggle notification categories.

**Estimated Complexity:** Medium.

**Estimated Development Time:** 8–12 hours (2 milestones).

**Phase-Level Review Checklist:** Notification categories map to feature flags for future selective rollout.

| # | Milestone | Objective | Deliverables | Files/Folders Affected | Dependencies | Risk | Est. Time |
|---|---|---|---|---|---|---|---|
| 17.1 | Notifications domain/data | Entity, repository, mock push simulation | `features/notifications/lib/src/domain/`, `data/` | 15.1 | Low | 3–5h |
| 17.2 | Notifications presentation | Center screen/bloc + preferences | `features/notifications/lib/src/presentation/` | 17.1 | Medium | 4–6h |

---

## Phase 18 — Profile

**Purpose:** Account management surface for the logged-in user.

**Deliverables:** Profile view/edit, address book management (reuses Checkout's Address entity).

**Dependencies:** Phase 7, Phase 14.1 (Address entity).

**Completion Criteria:** User can edit profile fields and manage a list of saved addresses shared with checkout.

**Estimated Complexity:** Medium.

**Estimated Development Time:** 8–12 hours (2 milestones).

**Phase-Level Review Checklist:** Address entity reused (not duplicated) from `core/shared_entities` or `checkout` domain per the exception rule in `02_PROJECT_STRUCTURE.md` §11.4.

| # | Milestone | Objective | Deliverables | Files/Folders Affected | Dependencies | Risk | Est. Time |
|---|---|---|---|---|---|---|---|
| 18.1 | Profile domain/data | Profile use cases atop `User`, address book use cases | `features/profile/lib/src/domain/`, `data/` | 7.1, 14.1 | Medium | 4–5h |
| 18.2 | Profile presentation | View/edit profile, address book screens | `features/profile/lib/src/presentation/` | 18.1 | Medium | 4–7h |

---

## Phase 19 — Settings

**Purpose:** App-level preferences and security controls.

**Deliverables:** Theme mode, language, security settings (change password, biometric toggle placeholder).

**Dependencies:** Phase 3 (feature flags/config), Phase 7 (auth for password change).

**Completion Criteria:** Theme/language changes apply live and persist; settings screen fully navigable.

**Estimated Complexity:** Low-Medium.

**Estimated Development Time:** 6–10 hours (2 milestones).

**Phase-Level Review Checklist:** Theme switch uses design-system tokens (no hardcoded overrides); language switch is i18n-ready even if only one locale ships.

| # | Milestone | Objective | Deliverables | Files/Folders Affected | Dependencies | Risk | Est. Time |
|---|---|---|---|---|---|---|---|
| 19.1 | Settings domain/data | AppSettings entity, persistence use cases | `features/settings/lib/src/domain/`, `data/` | 3.1, 7.1 | Low | 3–4h |
| 19.2 | Settings presentation | Settings screen, theme/language/security sections | `features/settings/lib/src/presentation/` | 19.1 | Medium | 3–6h |

---

## Phase 20 — Support

**Purpose:** Self-service and assisted support channel.

**Deliverables:** FAQ/help center, contact/create-ticket flow, ticket status screen.

**Dependencies:** Phase 7.

**Completion Criteria:** User can browse FAQ, submit a mock ticket, and view its (mock) status.

**Estimated Complexity:** Low-Medium.

**Estimated Development Time:** 8–12 hours (2 milestones).

**Phase-Level Review Checklist:** FAQ content is data-driven (mock CMS-like structure), not hardcoded widget text, to anticipate future CMS integration.

| # | Milestone | Objective | Deliverables | Files/Folders Affected | Dependencies | Risk | Est. Time |
|---|---|---|---|---|---|---|---|
| 20.1 | Support domain/data | FaqItem, SupportTicket entities/use cases | `features/support/lib/src/domain/`, `data/` | 7.1 | Low | 3–5h |
| 20.2 | Support presentation | Help center, contact/ticket screens | `features/support/lib/src/presentation/` | 20.1 | Medium | 4–7h |

---

## Phase 21 — Admin Foundation

**Purpose:** Stand up the admin app's own auth/RBAC/shell before any admin feature is built.

**Deliverables:** Admin auth (reusing `authentication` domain + `AdminRole` model), role-aware side nav shell, role-based route guards.

**Dependencies:** Phase 7, Phase 5.2.

**Completion Criteria:** Admin users with different roles (e.g., SuperAdmin, CatalogManager, SupportAgent) see different nav items and are blocked from unauthorized routes.

**Estimated Complexity:** High (security-relevant).

**Estimated Development Time:** 14–18 hours (3 milestones).

**Phase-Level Review Checklist:** Role checks enforced at the router/guard level, not just hidden in UI (hiding a nav item is not sufficient security).

| # | Milestone | Objective | Deliverables | Files/Folders Affected | Dependencies | Risk | Est. Time |
|---|---|---|---|---|---|---|---|
| 21.1 | Admin auth & role model | `AdminRole`, permission mapping, reuse of auth use cases | `features/authentication/lib/src/domain/` (extend), admin-specific wrapper in `admin_dashboard` or new `admin_auth` concern | 7.1 | High | 4–6h |
| 21.2 | Admin shell | Side nav, role-based menu visibility | `apps/admin/lib/app/app_shell.dart` | 21.1, 4.6 | Medium | 4–6h |
| 21.3 | Admin route guards | Role-based guard wired into admin router | `packages/core/lib/routing/`, `apps/admin/lib/app/app_router.dart` | 21.1, 5.2–5.3 | High | 3–6h |

---

## Phase 22 — Admin Dashboard & Analytics

**Purpose:** Give admins visibility into store performance.

**Deliverables:** Analytics aggregation use cases, KPI charts, reports screen.

**Dependencies:** Phase 21, Phase 15 (order data feeds analytics).

**Completion Criteria:** Dashboard shows sales/traffic/order KPIs from mock data with working chart interactions and a basic exportable report table.

**Estimated Complexity:** Medium-High.

**Estimated Development Time:** 12–18 hours (3 milestones).

**Phase-Level Review Checklist:** Charts degrade gracefully to empty state with zero data; report table paginates.

| # | Milestone | Objective | Deliverables | Files/Folders Affected | Dependencies | Risk | Est. Time |
|---|---|---|---|---|---|---|---|
| 22.1 | Analytics domain/data | Aggregation use cases, mock analytics fixtures | `features/analytics_reports/lib/src/domain/`, `data/` | 15.1, 21.1 | Medium | 4–6h |
| 22.2 | Analytics dashboard presentation | Chart-driven dashboard screen | `features/admin_dashboard/lib/src/presentation/` (extend Phase 8.4) | 22.1, 4.6 | Medium | 4–6h |
| 22.3 | Reports screen | Tabular/exportable summary | `features/analytics_reports/lib/src/presentation/` | 22.1 | Medium | 4–6h |

---

## Phase 23 — Admin Catalog & Inventory

**Purpose:** Let admins manage the product catalog and stock levels created for the storefront.

**Deliverables:** Product CRUD (admin), category CRUD (admin), inventory adjustment.

**Dependencies:** Phase 9 (products domain), Phase 10 (categories domain), Phase 21.

**Completion Criteria:** Admin can create a product, see it appear in the storefront's mock product list, adjust stock, and see a low-stock alert trigger.

**Estimated Complexity:** High (largest admin data-management surface).

**Estimated Development Time:** 20–28 hours (5 milestones).

**Phase-Level Review Checklist:** Admin CRUD use cases live in `admin_catalog`/`admin_inventory` domain but operate through the same `ProductRepository`/`CategoryRepository` interfaces as the storefront (single source of truth for mock data); forms fully validated.

| # | Milestone | Objective | Deliverables | Files/Folders Affected | Dependencies | Risk | Est. Time |
|---|---|---|---|---|---|---|---|
| 23.1 | Admin product management domain/data | Create/Update/Delete use cases atop `ProductRepository` | `features/admin_catalog/lib/src/domain/`, `data/` | 9.1–9.2, 21.1 | Medium | 4–6h |
| 23.2 | Product list & form (admin) | Data table + create/edit form | `features/admin_catalog/lib/src/presentation/` | 23.1, 4.6 | Medium | 5–7h |
| 23.3 | Category management (admin) | CRUD screens for categories | `features/admin_catalog/lib/src/presentation/` | 10.1, 23.1 | Medium | 4–6h |
| 23.4 | Inventory domain/data | StockLevel entity, adjust-stock use case | `features/admin_inventory/lib/src/domain/`, `data/` | 9.1, 21.1 | Medium | 3–5h |
| 23.5 | Inventory presentation | Stock management screen, low-stock alerts | `features/admin_inventory/lib/src/presentation/` | 23.4 | Medium | 4–6h |

---

## Phase 24 — Admin Orders & Customers

**Purpose:** Operational management of orders and customers.

**Deliverables:** Admin order table with status update/filter, customer list/detail.

**Dependencies:** Phase 15 (orders domain), Phase 7 (user/customer domain), Phase 21.

**Completion Criteria:** Admin can filter orders by status, update an order's status (reflected in customer's order history), and view a customer's profile/order history.

**Estimated Complexity:** Medium-High.

**Estimated Development Time:** 14–18 hours (3 milestones).

**Phase-Level Review Checklist:** Status transitions respect a defined state machine (no illegal transitions from the UI).

| # | Milestone | Objective | Deliverables | Files/Folders Affected | Dependencies | Risk | Est. Time |
|---|---|---|---|---|---|---|---|
| 24.1 | Admin order management | Order table, filters, status update use case | `features/admin_orders/lib/src/domain/`, `data/`, `presentation/` | 15.1, 21.1 | Medium | 5–7h |
| 24.2 | Admin customer management domain/data | Customer aggregation use cases (profile + order history) | `features/admin_customers/lib/src/domain/`, `data/` | 7.1, 15.1, 21.1 | Medium | 4–5h |
| 24.3 | Customer list/detail presentation | Screens for browsing/viewing customers | `features/admin_customers/lib/src/presentation/` | 24.2 | Medium | 4–6h |

---

## Phase 25 — Marketing

**Purpose:** Promotional tools for admins to drive storefront conversion.

**Deliverables:** Promotion/coupon management, banner management (feeds storefront home banners from Phase 8.1).

**Dependencies:** Phase 21, Phase 13.1 (promo code contract), Phase 8.1 (banners).

**Completion Criteria:** Admin creates a coupon usable in the storefront cart, and a banner created in admin appears on the storefront home.

**Estimated Complexity:** Medium.

**Estimated Development Time:** 12–16 hours (2 milestones).

**Phase-Level Review Checklist:** Coupon validation rules (expiry, min spend, usage limit) unit-tested.

| # | Milestone | Objective | Deliverables | Files/Folders Affected | Dependencies | Risk | Est. Time |
|---|---|---|---|---|---|---|---|
| 25.1 | Marketing domain/data | Promotion, Coupon, Banner entities/use cases | `features/marketing/lib/src/domain/`, `data/` | 13.1, 8.1, 21.1 | Medium | 5–7h |
| 25.2 | Marketing presentation | Management screens for promotions/coupons/banners | `features/marketing/lib/src/presentation/` | 25.1, 4.6 | Medium | 6–9h |

---

## Phase 26 — White-Label & Tenant Management

**Purpose:** Expose the tenant/branding configuration built in Phase 3 through an actual admin UI, and prove the white-label promise end-to-end.

**Deliverables:** Tenant profile CRUD over `TenantConfig`, branding editor, feature flag toggle UI, second demo-tenant verification.

**Dependencies:** Phase 3, Phase 21.

**Completion Criteria:** Creating a second tenant configuration and switching to it changes logo/colors/copy/enabled-features across both apps with **zero code changes**.

**Estimated Complexity:** High (this is the platform's core value proposition).

**Estimated Development Time:** 14–20 hours (3 milestones).

**Phase-Level Review Checklist:** Every tenant-overridable surface identified in `05_ARCHITECTURE_GUIDELINES.md` is actually wired to `TenantConfig`, not hardcoded.

| # | Milestone | Objective | Deliverables | Files/Folders Affected | Dependencies | Risk | Est. Time |
|---|---|---|---|---|---|---|---|
| 26.1 | Tenant management domain/data | TenantProfile CRUD use cases over config store | `features/tenant_management/lib/src/domain/`, `data/` | 3.2, 21.1 | Medium | 4–6h |
| 26.2 | Branding editor & flag toggles | Admin UI to edit branding/copy/flags | `features/tenant_management/lib/src/presentation/` | 26.1, 4.x | Medium | 5–8h |
| 26.3 | Rebrand verification milestone | Create 2nd demo tenant, verify zero-code-change rebrand across both apps | Verification report (docs), no new production code | `docs/adr/` (record outcome) | 26.1–26.2 | Medium | 3–4h |

---

## Phase 27 — Optimization & Hardening

**Purpose:** Cross-cutting quality pass after all features exist.

**Deliverables:** Responsive audit, accessibility audit, performance audit, dark mode audit — with fixes applied.

**Dependencies:** All feature phases (7–26).

**Completion Criteria:** Every screen in `07_SCREEN_CATALOG.md` passes its responsive/tablet/desktop/dark-mode/a11y checklist.

**Estimated Complexity:** Medium (breadth, not depth).

**Estimated Development Time:** 20–30 hours (4 milestones).

**Phase-Level Review Checklist:** No screen breaks below 360px width or above 1440px width; contrast ratios meet WCAG AA; list views virtualize beyond ~50 items.

| # | Milestone | Objective | Deliverables | Files/Folders Affected | Dependencies | Risk | Est. Time |
|---|---|---|---|---|---|---|---|
| 27.1 | Responsive audit | Fix breakpoint issues across all screens | Various presentation files | All prior | Medium | 6–8h |
| 27.2 | Accessibility audit | Semantics labels, contrast, tap target sizing | Various | All prior | Medium | 5–7h |
| 27.3 | Performance pass | List virtualization, image caching, startup time | Various + `pubspec.yaml` deps review | All prior | Medium | 5–8h |
| 27.4 | Dark mode audit | Verify token-driven dark theme across all screens | `design_system/theme/`, various screens | 4.2, all prior | Low | 4–7h |

---

## Phase 28 — Documentation & QA Pass

**Purpose:** Execute the full manual test plan and true-up all documentation before delivery.

**Deliverables:** Completed manual test run, defect fixes, finalized docs.

**Dependencies:** Phase 27.

**Completion Criteria:** Zero open Critical/High defects; all docs in `docs/` reflect the as-built system.

**Estimated Complexity:** Medium.

**Estimated Development Time:** 16–24 hours (3 milestones).

**Phase-Level Review Checklist:** Every checklist item in `12_MANUAL_TEST_PLAN.md` executed and recorded with pass/fail.

| # | Milestone | Objective | Deliverables | Files/Folders Affected | Dependencies | Risk | Est. Time |
|---|---|---|---|---|---|---|---|
| 28.1 | Execute manual test plan | Full pass through `12_MANUAL_TEST_PLAN.md`, log defects | QA log (docs or issue tracker) | All prior | Medium | 6–10h |
| 28.2 | Fix & re-test | Resolve Critical/High defects | Various | 28.1 | Medium-High | 6–10h |
| 28.3 | Documentation true-up | Reconcile docs 01–14 with as-built system, update progress tracker | `docs/*.md` | 28.1–28.2 | Low | 4–4h |

---

## Phase 29 — Client Ready Review

**Purpose:** Final gate before handoff.

**Deliverables:** Completed `13_CLIENT_DELIVERY_CHECKLIST.md`, stakeholder sign-off.

**Dependencies:** Phase 28.

**Completion Criteria:** All items in `13_CLIENT_DELIVERY_CHECKLIST.md` checked; stakeholder sign-off recorded.

**Estimated Complexity:** Low (process, not engineering).

**Estimated Development Time:** 4–8 hours (2 milestones).

**Phase-Level Review Checklist:** Every checklist section in doc 13 signed off by its responsible role (Engineering, QA, Design, DevOps, PM).

| # | Milestone | Objective | Deliverables | Files/Folders Affected | Dependencies | Risk | Est. Time |
|---|---|---|---|---|---|---|---|
| 29.1 | Run delivery checklist | Walk through and check off `13_CLIENT_DELIVERY_CHECKLIST.md` | Checklist doc updated | 28.x | Low | 3–5h |
| 29.2 | Stakeholder sign-off | Present final build, obtain approval | Sign-off record in `docs/adr/` | 29.1 | Low | 1–3h |

---

## Total Estimated Effort

Summing phase ranges yields an approximate **340–470 developer-hours** (~9–12 weeks for a single senior full-stack Flutter engineer, less with parallelization across independent feature packages once Phases 1–6 are complete). This estimate covers Phase 1 (mock-data) scope only, per `01_IMPLEMENTATION_PLAN.md` §4.2; Firebase backend integration is a separate, subsequently scoped effort.
