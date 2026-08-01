# 01 — Implementation Plan

**Document Status:** Master Planning Document
**Project:** White Label Commerce Platform (WLCP)
**Version:** 1.0.0
**Owner:** Lead Architecture Team
**Companion Documents:** `02` through `14` in this `docs/` folder

> This document is the single source of truth for the project. No implementation work begins until this document (and its companions) is reviewed and approved. All other documents in this folder derive their structure, naming, and sequencing from the decisions recorded here.

---

## 1. Project Vision

Build a **production-ready, multi-tenant, white-label e-commerce platform** delivered as three coordinated Flutter experiences (Customer Mobile, Customer Web, Admin Panel) sharing a single Clean Architecture codebase.

The platform must be:

- **Sellable** to multiple enterprise clients (retailers, brands, marketplaces) without forking the codebase.
- **Rebrandable** per client (theme, logo, copy, feature flags) via configuration, not code changes.
- **Backend-agnostic during Phase 1** — built entirely against local mock data behind repository interfaces, then wired to Firebase without touching UI or business logic layers.
- **Enterprise-grade** in code quality, testability, documentation, and operational readiness (CI/CD, environments, observability).

The end state is a platform a Technical Project Manager can hand to a new enterprise client, configure in hours (not weeks), and deploy to app stores, web hosting, and admin hosting with confidence.

---

## 2. Goals

1. Establish a Clean Architecture, Feature-First Flutter monorepo that scales to dozens of features without architectural erosion.
2. Support **three delivery targets** from one codebase: Mobile app (iOS/Android), Web storefront, Web-first Admin Panel.
3. Ship the full customer commerce journey: browse → search → wishlist → cart → checkout → orders → payments → notifications → support.
4. Ship a full Admin Panel: dashboard, product/inventory management, order management, customer management, marketing, analytics/reports, tenant/white-label management.
5. Make every feature independently testable, independently reviewable, and independently shippable as a milestone.
6. Design the data layer so swapping Mock → Firebase requires **zero changes** to domain or presentation layers (Repository Pattern + DI binding swap only).
7. Design theming, copy, and feature availability to be **tenant-configurable** (multi-tenant / white-label ready) from day one, even while only one tenant exists.
8. Produce documentation thorough enough that any senior Flutter engineer can execute the build without further architectural decision-making.
9. Keep every milestone small (2–6 hours), independently reviewable, and always leaving the app in a runnable state.

## 3. Non-Negotiable Constraints

- No application code, widgets, blocs, repositories, or screens are produced in this planning phase.
- Firebase integration is **deferred**; Phase 1 delivery must be fully functional on mock data alone.
- Every feature must ship with presentation, domain, and data layers — no exceptions, no "temporary" shortcuts.
- Every repository must have both an interface and a mock implementation before any UI consumes it.

---

## 4. Scope

### 4.1 In Scope

| Area | Included |
|---|---|
| Platforms | Flutter Mobile (iOS + Android), Flutter Web (storefront), Flutter Admin Panel (web-first, responsive to tablet/desktop) |
| Architecture | Clean Architecture, Feature-First modularization, flutter_bloc, go_router, get_it + injectable DI |
| Data Layer | Local mock repositories now; Firebase-ready repository contracts for later swap |
| Customer Features | Authentication, Dashboard/Home, Products, Categories, Search, Wishlist, Cart, Checkout, Orders, Payments (mock gateway), Notifications, Profile, Settings, Support |
| Admin Features | Admin Auth/RBAC, Admin Dashboard, Product Management, Inventory, Order Management, Customer Management, Marketing/Promotions, Analytics & Reports, Tenant/White-Label Management, Staff & Roles |
| Cross-Cutting | Design System, Component Library, Routing, Error/Empty/Loading states, Developer Panel, Feature Flags, Multi-tenant theming |
| Quality | Manual QA test plan, review checklists per milestone, client delivery checklist |
| DevOps | Environment/flavor strategy, CI-ready structure, build verification steps |

### 4.2 Out of Scope (Phase 1 delivery)

- Live Firebase backend calls (structure is Firebase-ready; actual wiring is a later, separately scoped project phase — see `05_ARCHITECTURE_GUIDELINES.md` §13).
- Real payment gateway integration (Stripe/Razorpay/etc.) — mock payment flow only, with an abstraction ready for a real provider.
- Native platform-specific features beyond what Flutter + standard plugins provide out of the box (e.g., no custom native modules).
- Real push notification delivery (local/mock notification center only; FCM wiring documented but not implemented).
- Automated end-to-end/integration test automation (this plan mandates a **manual** QA process — see `12_MANUAL_TEST_PLAN.md`; automated testing is a recommended future enhancement, not a Phase 1 deliverable).
- Localization content translation (the architecture must be i18n-ready; translating into multiple languages is a client-specific, later activity).

## 5. Non-Goals

Explicitly **not** goals of this project, to prevent scope creep:

- This is not a generic Flutter starter template — it is a purpose-built commerce platform.
- This is not a backend project — Firebase Functions/security rules/cloud infra are referenced only where they affect frontend contracts.
- This is not a design agency deliverable — the Design System is functional and tenant-themeable, not a bespoke art direction exercise.
- This is not a single-tenant app with hardcoded branding — every visual/text/feature surface that could plausibly differ between clients must run through configuration.
- This is not a "big bang" delivery — the platform is built and reviewed in small, working increments; there is no milestone where the app is left in a non-compiling or non-runnable state.

---

## 6. Architecture Overview

> Full detail in `05_ARCHITECTURE_GUIDELINES.md`. Summary below for planning context.

- **Pattern:** Clean Architecture (Presentation → Domain → Data), enforced per feature.
- **Organization:** Feature-First. Each feature is a self-contained module with its own `presentation/`, `domain/`, `data/` subtrees.
- **State Management:** `flutter_bloc` (Bloc for multi-event flows, Cubit for simple state holders). No `setState`-driven business logic anywhere.
- **Routing:** `go_router` with a centralized route table, per-app router configuration (customer app vs admin app), guards for auth/role.
- **Dependency Injection:** `get_it` service locator + `injectable` code generation for registration. Each feature registers its own dependencies via an injectable module, composed at app startup.
- **Data Layer Strategy:** Repository Pattern. Domain layer defines abstract repository interfaces; Data layer provides `Mock*RepositoryImpl` now and `Firebase*RepositoryImpl` later, selected via DI binding + environment flavor — domain/presentation code never changes.
- **Multi-Tenant / White-Label:** A `TenantConfig`/`AppConfig` model (theme tokens, feature flags, copy overrides, branding assets) is injected at app bootstrap and consumed by the Design System and feature flag service. Adding a tenant means adding a config, not writing code.
- **Monorepo Topology:** A single repository containing shared packages and three thin app shells (Mobile+Web share one "storefront" app target; Admin is a second app target). See `02_PROJECT_STRUCTURE.md` for full rationale and layout.
- **Error Handling:** Functional-style `Result<Failure, T>` (Either-like) returned from repositories/use cases; UI never receives thrown exceptions from the domain layer.
- **Testability:** Every layer depends on abstractions, enabling unit tests for domain/data and widget tests for presentation without a real backend or emulator.

## 7. Folder Structure Strategy (Summary)

Full detail lives in `02_PROJECT_STRUCTURE.md`. Strategic principles:

1. **Apps are thin.** `apps/storefront` and `apps/admin` contain only bootstrap, DI composition, app-level routing composition, and flavor entry points — no business logic.
2. **Features are shared packages.** Each business feature lives under `packages/features/<feature_name>` so that both apps (and future apps) can reuse domain/data layers, and even presentation widgets where the UI is shared.
3. **Core is a package.** Cross-cutting infrastructure (networking, error types, DI setup helpers, use case base classes, logging, config) lives in `packages/core`.
4. **Design System is a package.** Tokens, theming, and the component library live in `packages/design_system`, consumed by both apps.
5. **Mock data is isolated.** Mock fixtures/providers live inside each feature's `data/mock/` layer, never in the app shell, so they can be swapped or disabled per environment.
6. **Naming is deterministic.** Folder and file naming conventions are fixed once in `02_PROJECT_STRUCTURE.md` and never deviate.

## 8. Development Strategy

- **Monorepo tooling:** Melos manages the multi-package workspace (bootstrap, versioning, running scripts across packages).
- **Feature-first, milestone-driven:** Development proceeds strictly in the dependency order defined in `04_FEATURE_IMPLEMENTATION_ORDER.md`, broken into 2–6 hour milestones defined in `03_DEVELOPMENT_PHASES.md`.
- **Always-shippable increments:** Every milestone ends with the app(s) compiling, running, and passing its own review checklist. No milestone leaves the tree in a broken state.
- **Mock-first, contract-first:** For every feature, the domain contracts (entities, repository interfaces, use cases) and mock data are built before any UI, so presentation work never blocks on data-layer ambiguity.
- **Documentation-as-you-go:** `14_IMPLEMENTATION_PROGRESS.md` is updated at the end of every milestone (⬜ → 🟨 → 🟩). This is mandatory, not optional.
- **Review gates:** Each milestone, phase, and the overall project has an explicit review checklist. Nothing proceeds to the next phase without passing its Definition of Done.
- **Backend deferral, not backend ignorance:** Every repository interface is written as if Firebase already exists (async, paginated, failure-typed) so the later integration phase is a pure implementation swap, not a redesign.

## 9. Milestones (Index)

Milestones are fully enumerated in `03_DEVELOPMENT_PHASES.md`. High-level index of major phases (each phase = multiple 2–6 hour milestones):

| # | Phase | Theme |
|---|---|---|
| 1 | Project Foundation | Monorepo, tooling, CI scaffolding, lint/format rules |
| 2 | Core Architecture | DI, error handling, networking abstraction, use case base classes |
| 3 | Environment & Configuration | Flavors, env vars, app config, feature flags, tenant config |
| 4 | Design System & Shared Widgets | Tokens, theming, base component library |
| 5 | Routing Foundation | go_router setup for both apps, guards, shells |
| 6 | Mock Data Infrastructure | Fixture strategy, mock data providers, seeding |
| 7 | Authentication | Login, register, forgot password, OTP, session |
| 8 | Dashboard / Home | Storefront home, admin dashboard shells |
| 9 | Products | Listing, detail, variants, reviews |
| 10 | Categories | Browsing, category detail |
| 11 | Search | Search, filters, sort, suggestions |
| 12 | Wishlist | Save/remove, wishlist screen |
| 13 | Cart | Cart management, pricing, promo codes |
| 14 | Checkout | Address, shipping, payment selection, review, confirmation |
| 15 | Orders | History, detail, tracking, returns/cancellation |
| 16 | Payments | Payment method management, mock gateway abstraction |
| 17 | Notifications | In-app center, preferences, mock push |
| 18 | Profile | User profile, addresses, account management |
| 19 | Settings | App settings, theme, language, security |
| 20 | Support | Help center, FAQ, contact/ticket |
| 21 | Admin Foundation | Admin shell, RBAC, admin auth |
| 22 | Admin Dashboard & Analytics | KPIs, charts, reports |
| 23 | Admin Catalog & Inventory | Product/category CRUD, stock management |
| 24 | Admin Orders & Customers | Order management, customer management |
| 25 | Marketing | Promotions, coupons, banners |
| 26 | White-Label & Tenant Management | Branding config UI, tenant switch, feature flags UI |
| 27 | Optimization & Hardening | Performance, accessibility, responsive polish |
| 28 | Documentation & QA Pass | Manual test pass, docs finalization |
| 29 | Client Ready Review | Final delivery checklist, sign-off |

## 10. Deliverables

By the end of the plan's execution, the following are delivered:

1. A Melos-managed monorepo with `packages/core`, `packages/design_system`, `packages/features/*`, `apps/storefront`, `apps/admin`.
2. A fully functional customer storefront (mobile + web) running entirely on mock data, covering every feature listed in §4.1.
3. A fully functional admin panel running entirely on mock data, covering every admin feature listed in §4.1.
4. A component library documented in `08_COMPONENT_LIBRARY.md` and implemented as reusable widgets in `packages/design_system`.
5. A routing plan implemented via `go_router` per `09_ROUTING_PLAN.md`.
6. Firebase-ready repository contracts and a documented integration strategy (`10_DATA_FLOW.md`).
7. Environment/flavor configuration for `dev`, `staging`, `production`, per client tenant, documented in `11_ENVIRONMENT_CONFIGURATION.md`.
8. A completed manual test pass following `12_MANUAL_TEST_PLAN.md`.
9. A completed `13_CLIENT_DELIVERY_CHECKLIST.md` for at least one pilot tenant.
10. A continuously updated `14_IMPLEMENTATION_PROGRESS.md` reflecting true project state at all times.

## 11. Dependencies

### 11.1 Tooling / SDK

| Dependency | Purpose | Notes |
|---|---|---|
| Flutter SDK (stable channel) | Core framework | Pin exact version in `.fvmrc` / `pubspec.yaml` once selected at Phase 1 kickoff |
| Dart SDK | Language runtime | Bundled with Flutter |
| Melos | Monorepo management | Bootstrap, versioning, cross-package scripts |
| flutter_bloc | State management | Bloc/Cubit |
| go_router | Routing | Declarative navigation, guards |
| get_it | Service locator | DI container |
| injectable | DI codegen | Reduces manual `get_it` registration |
| freezed / json_serializable | Immutable models, unions, serialization | Entities, DTOs, Failure types |
| equatable | Value equality | Entities, states, events |
| dartz (or custom `Result` type) | Functional error handling | Either-style `Result<Failure, T>` |
| build_runner | Codegen runner | freezed/injectable/json_serializable |
| flutter_lints / very_good_analysis | Static analysis | Enforced lint baseline |
| mocktail | Mocking in unit tests | Domain/data layer tests |
| bloc_test | Bloc/Cubit testing | State transition verification |
| firebase_core, firebase_auth, cloud_firestore, firebase_storage, firebase_messaging, firebase_remote_config | Future backend integration | Added but not wired to live calls in Phase 1 |
| intl | i18n/l10n | Locale-ready copy from day one |
| flutter_svg, cached_network_image | Asset/image handling | Design system, product imagery |
| shared_preferences / hive | Local persistence | Session cache, offline cache, dev panel state |

### 11.2 External / Organizational Dependencies

- Design tokens / brand guidelines for at least one pilot tenant (needed before Design System phase can be finalized).
- Firebase project(s) provisioned per environment (dev/staging/prod) — needed only before the later backend-integration project, not for this plan's Phase 1 scope.
- App Store / Play Store developer accounts — needed before `13_CLIENT_DELIVERY_CHECKLIST.md` can be fully completed.
- Hosting target decision for Web storefront and Admin Panel (e.g., Firebase Hosting) — needed before deployment milestones.

## 12. Estimated Complexity

| Area | Complexity | Rationale |
|---|---|---|
| Monorepo & Core Architecture | High | Gets the foundational contracts right; mistakes here are expensive to fix later |
| Design System | Medium | Broad surface area, but mechanically repetitive once tokens are defined |
| Routing | Medium-High | Two apps, guarded routes, nested shells, deep links |
| Customer Commerce Features (Products→Payments) | High | Largest functional surface, most business rules (pricing, stock, promo codes) |
| Admin Panel | High | Data-dense UI, tables, RBAC, bulk operations |
| Multi-Tenant / White-Label | High | Cross-cutting; must be retrofitted correctly into every layer, not bolted on |
| Mock → Firebase readiness | Medium | Contracts are designed up front; actual Firebase wiring is a separate later project |
| QA / Manual Test Plan execution | Medium | Broad checklist, execution time scales with feature count |

**Overall project complexity: High.** Primary risk driver is breadth (three platforms, ~20 customer/admin features, multi-tenant theming) rather than depth of any single feature.

## 13. Risk Analysis

| # | Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|---|
| R1 | Feature boundaries blur, causing cross-feature imports and tight coupling | Medium | High | Enforced in `06_DEVELOPMENT_RULES.md`; lint/import-boundary review at every milestone |
| R2 | Mock data diverges from realistic Firebase data shape, causing rework at integration time | Medium | High | Repository interfaces designed async/paginated/failure-typed from day one; mock DTOs mirror planned Firestore documents (`10_DATA_FLOW.md`) |
| R3 | White-label theming retrofitted late, requiring widget rewrites | Low (mitigated by design) | High | Design System and `AppConfig`/`TenantConfig` built in Phase 3–4, before any feature UI exists |
| R4 | Admin Panel and Storefront apps duplicate logic instead of sharing feature packages | Medium | Medium | Feature packages own domain/data; only presentation widgets that are genuinely app-specific live in the app shells |
| R5 | Milestones grow too large, losing reviewability | Medium | Medium | Hard 2–6 hour cap enforced in `03_DEVELOPMENT_PHASES.md`; oversized milestones must be split before starting |
| R6 | State management inconsistency (mixing setState, Provider, Bloc) | Low | High | `06_DEVELOPMENT_RULES.md` mandates flutter_bloc exclusively for business/state logic |
| R7 | Routing guards inconsistently applied across customer/admin apps, causing auth bypass | Medium | High | Centralized guard logic in `packages/core`, reused by both routers; verified in `09_ROUTING_PLAN.md` and manual test plan |
| R8 | Progress tracking document goes stale, losing its value as source of truth | Medium | Medium | Update `14_IMPLEMENTATION_PROGRESS.md` made a Definition-of-Done requirement for every milestone |
| R9 | Scope creep beyond documented feature list mid-development | Medium | Medium | Any new feature request requires updating `04_FEATURE_IMPLEMENTATION_ORDER.md` and `01_IMPLEMENTATION_PLAN.md` before implementation starts |
| R10 | Payment/notification mocking creates false confidence that real integration will be trivial | Low | Medium | Abstractions documented explicitly as "integration seams" in `10_DATA_FLOW.md`, with known unknowns called out |

## 14. Success Criteria

The Phase 1 (mock-data) delivery is considered successful when:

1. Both apps (`storefront`, `admin`) build and run on Mobile, Web, and (for admin) Desktop/Web without errors, using only mock data.
2. Every feature in §4.1 has complete presentation/domain/data layers per `06_DEVELOPMENT_RULES.md`.
3. Every screen in `07_SCREEN_CATALOG.md` implements loading, empty, and error states.
4. The manual test plan (`12_MANUAL_TEST_PLAN.md`) passes with zero open Critical/High severity defects.
5. Rebranding to a second fictitious tenant (new colors, logo, name, one disabled feature flag) requires **no code changes** — only configuration changes — and is demonstrated end-to-end.
6. `14_IMPLEMENTATION_PROGRESS.md` shows 100% 🟩 Completed for all in-scope milestones.
7. The `13_CLIENT_DELIVERY_CHECKLIST.md` is fully checked off for the pilot tenant.
8. A senior engineer unfamiliar with the project can read `02`–`10` and correctly predict where any new feature's files would live, without asking questions.

## 15. Client Readiness Checklist (Summary)

Full checklist in `13_CLIENT_DELIVERY_CHECKLIST.md`. Top-level gates:

- [ ] All builds green (mobile debug/release, web release, admin release).
- [ ] All manual test suites passed and signed off.
- [ ] Branding/theming verified against client brand guideline for pilot tenant.
- [ ] Firebase project structure documented and ready for integration phase (even though not wired live).
- [ ] App Store / Play Store metadata and assets prepared.
- [ ] Web storefront and Admin Panel deployment targets configured.
- [ ] Security review of auth flows, route guards, and role-based access completed.
- [ ] Documentation package (`docs/` folder) delivered alongside source.

---

## 16. Document Map

| Doc | Purpose |
|---|---|
| `01_IMPLEMENTATION_PLAN.md` | This document — master vision, scope, milestones index, risk |
| `02_PROJECT_STRUCTURE.md` | Full folder structure and naming conventions |
| `03_DEVELOPMENT_PHASES.md` | Phases broken into 2–6 hour milestones with DoD |
| `04_FEATURE_IMPLEMENTATION_ORDER.md` | Every feature, in dependency order, with full contract outline |
| `05_ARCHITECTURE_GUIDELINES.md` | Clean Architecture rules, DI, patterns, future backend strategy |
| `06_DEVELOPMENT_RULES.md` | Mandatory rules Cursor/engineers must follow |
| `07_SCREEN_CATALOG.md` | Every screen, fully specified |
| `08_COMPONENT_LIBRARY.md` | Every reusable component, fully specified |
| `09_ROUTING_PLAN.md` | Complete routing strategy for both apps |
| `10_DATA_FLOW.md` | Mock → Domain → Bloc → UI → future Firebase data flow |
| `11_ENVIRONMENT_CONFIGURATION.md` | Environments, flavors, secrets, feature flags |
| `12_MANUAL_TEST_PLAN.md` | Full manual QA checklist |
| `13_CLIENT_DELIVERY_CHECKLIST.md` | Everything required before client handoff |
| `14_IMPLEMENTATION_PROGRESS.md` | Live status tracker (⬜ / 🟨 / 🟩) |

**Approval required before any code is written.**
