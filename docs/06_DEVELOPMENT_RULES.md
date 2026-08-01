# 06 — Development Rules

**Status:** Mandatory rules. These are binding on every engineer and on Cursor (or any AI coding agent) working on this codebase. A pull request / milestone that violates any rule below is not complete, regardless of whether the feature "works."

Rules are grouped by theme. Each rule includes a one-line rationale so it isn't cargo-culted.

---

## 1. Architecture & Layering Rules

1. **Never put business logic inside a widget.** `build()` methods only read state and dispatch events/call bloc methods. *Why: widgets are the least testable, least reusable layer — logic there can't be unit tested.*
2. **Never access a repository or data source directly from a widget or screen.** Widgets talk to Blocs/Cubits; Blocs/Cubits talk to use cases; use cases talk to repositories. *Why: preserves the one seam needed to swap Mock → Firebase later.*
3. **Never import a `data/` file from `presentation/`.** Presentation only imports `domain/` (entities, use cases) and `design_system`/`core`. *Why: this is the Dependency Rule; violating it couples UI to a specific backend.*
4. **Never use `BuildContext` inside a repository, data source, use case, or Bloc/Cubit.** *Why: these layers must be usable outside the widget tree (unit tests, background isolates) and must never assume a `context` is available or valid.*
5. **Never import one feature package's `src/` internals from another feature.** Only the target feature's barrel export (`<feature>.dart`) may be imported cross-feature, and only for domain-layer symbols (entities, use cases) explicitly documented as a dependency in `04_FEATURE_IMPLEMENTATION_ORDER.md`. *Why: keeps the dependency graph acyclic and features independently replaceable.*
6. **Never let `packages/core` or `packages/design_system` import from any feature package or from `apps/*`.** *Why: they are the base of the dependency graph; a reverse import creates a cycle.*
7. **Every feature must have `presentation/`, `domain/`, and `data/` subtrees — no exceptions, including "simple" features.** *Why: consistency lets any engineer navigate any feature identically; "simple today" features grow complexity over time.*
8. **Every feature must be independently testable** — its domain and data layers must run in unit tests with zero Flutter widget/engine dependency, and its presentation layer must be testable via `bloc_test`/`flutter_test` without a running backend. *Why: this is the entire point of Clean Architecture; a feature that can't be tested in isolation isn't actually isolated.*
9. **Never duplicate a widget that already exists in `design_system` or in the current feature.** Search `08_COMPONENT_LIBRARY.md` and the feature's existing `presentation/widgets/` before creating a new one. *Why: duplicate buttons/cards/dialogs are the #1 cause of visual and behavioral drift in white-label products.*
10. **Never hardcode a color, spacing value, font size, or radius.** Always reference a `design_system` token (`AppColors.*`, `AppSpacing.*`, etc.). *Why: white-labeling requires every visual value to be tenant-overridable through the theme, not sprinkled as magic numbers.*
11. **Never branch application behavior on tenant identity in code** (e.g. `if (tenant.id == 'acme')`). Tenant differences must be expressed as `TenantConfig`/`FeatureFlags` data. *Why: code branches per tenant defeat the entire white-label architecture and don't scale past 2 clients.*

## 2. State Management Rules

12. **`flutter_bloc` is the only sanctioned state management solution for business/application state.** No Provider, Riverpod, GetX, or raw `InheritedWidget` for state that has business meaning. *Why: one paradigm, one learning curve, one debugging story across the whole platform.*
13. **`setState` is allowed only for purely ephemeral, non-business UI state** (animation flags, focus, scroll position) that has zero persistence or business-rule implication. *Why: keeps a single source of truth for anything a QA tester or a bug report could care about.*
14. **Every Bloc/Cubit state class must be immutable** (`freezed` or `Equatable`-backed). *Why: enables reliable `bloc_test` assertions and prevents subtle mutation bugs.*
15. **A Bloc/Cubit never holds a direct reference to another Bloc/Cubit's internals.** Cross-bloc communication happens via stream subscriptions or shared use cases only. *Why: prevents hidden coupling that breaks independent testability.*
16. **No Bloc/Cubit ever imports `flutter/material.dart` for UI purposes.** *Why: keeps the state layer testable without the Flutter widget/engine bindings.*

## 3. Screen & UX Contract Rules

17. **Every screen that loads async data must implement a Loading state.** *Why: unhandled loading states are the most common source of "frozen UI" bug reports.*
18. **Every screen that lists data must implement an Empty state**, distinct from Loading and Error, with tenant-copy-overridable messaging. *Why: an empty list rendered with no explanation reads as a bug to users and QA alike.*
19. **Every screen that depends on async data must implement an Error state** with a retry action, mapped from a typed `Failure` via the shared `FailureMessageMapper`. *Why: raw exceptions or blank screens are unacceptable in an enterprise product.*
20. **Every form must have field-level validation before submission is enabled**, using shared validators from `core/utils/validators.dart` where a shared rule exists (email, phone, password). *Why: consistent validation logic and consistent UX for identical field types across features.*
21. **Every screen must declare and support its responsive behavior** (mobile / tablet / desktop) per `07_SCREEN_CATALOG.md` — no screen ships "mobile-only" if the catalog specifies tablet/desktop behavior. *Why: Flutter Web + Admin Panel both require multi-breakpoint support from day one.*
22. **Every destructive or irreversible action (delete, cancel order, suspend customer, remove payment method) requires an explicit confirmation step.** *Why: enterprise admin tools are judged harshly on accidental-data-loss risk.*

## 4. Data & Repository Rules

23. **Every repository must have an abstract interface in `domain/repositories/`, defined before any implementation.** *Why: the interface is the contract presentation code is written against; writing it first prevents leaking data-layer concerns upward.*
24. **Every repository must have a mock implementation before any UI consumes it.** No screen is built against a repository that returns hardcoded values inline in the Bloc — mock implementations belong in the Data layer, not smuggled into Presentation. *Why: keeps the Mock→Firebase swap boundary exactly where it belongs.*
25. **Every repository method returns `Result<Failure, T>` (or `Stream<Result<Failure, T>>`) — never a bare value with thrown exceptions crossing the repository boundary.** *Why: forces every call site to explicitly handle failure, rather than relying on uncaught-exception behavior.*
26. **Every list-returning repository method must be paginated via the shared `PaginatedResult<T>` envelope**, even in Phase 1 with small mock datasets. *Why: retrofitting pagination after screens are built against a flat `List<T>` is expensive; designing for it now costs nothing.*
27. **Mock data sources must simulate latency and at least one failure-injection path.** A repository that always resolves instantly and never fails hides real bugs in loading/error UI until production. *Why: catches missing loading/error states during development, not during QA.*
28. **DTOs (Models) are never used outside the Data layer.** Entities cross into Domain/Presentation; Models stay inside `data/`. *Why: prevents serialization concerns (JSON keys, Firestore field names) leaking into business logic or UI.*

## 5. Documentation & API Rules

29. **Every public class, method, and property in `core`, `design_system`, and every feature's `domain/` layer must be documented with a `///` doc comment explaining intent, not restating the signature.** *Why: this codebase is sold to enterprise clients and handed to teams who did not build it; undocumented public APIs are a liability.*
30. **Every non-obvious architectural decision that deviates from this document set must be recorded as an ADR in `docs/adr/`, cross-referenced from the affected numbered doc.** *Why: keeps the documentation set trustworthy as the single source of truth over the life of the project.*
31. **No comment narrates *what* code does; comments explain *why*, when the *why* isn't obvious from the code itself.** *Why: narrating comments rot immediately and add noise; intent comments stay useful.*

## 6. Testing Rules

32. **Every new use case and repository implementation ships with unit tests covering at least: happy path, one failure path, and one edge case** (empty input, boundary value). *Why: domain/data logic is the cheapest layer to test and the most valuable to keep regression-safe.*
33. **Every new Bloc/Cubit ships with `bloc_test` coverage for its primary state transitions**, including at minimum one Loading→Loaded and one Loading→Error sequence. *Why: state machines are where subtle bugs hide; sequence tests catch them cheaply.*
34. **No milestone is marked 🟩 Completed in `14_IMPLEMENTATION_PROGRESS.md` without its tests passing.** *Why: "done" means verifiably done, not "looks done in the simulator."*

## 7. Dependency Injection Rules

35. **Every feature registers its own dependencies via a `<Feature>InjectionModule`; the app shell only calls that module's registration entry point, never registers a feature's internals directly.** *Why: keeps feature packages self-contained and relocatable.*
36. **Long-lived, session-scoped Blocs (`AuthBloc`, `CartBloc`, `WishlistCubit`, `NotificationBloc`) are singletons provided once at the app-shell root; screen-scoped Blocs are factories provided per route.** *Why: prevents both memory leaks (over-scoping) and lost state on navigation (under-scoping).*

## 8. Multi-Tenant / White-Label Rules

37. **Every user-facing string that could plausibly differ by client (brand name, support email, empty-state copy, marketing copy) must be sourced from `TenantConfig.copyOverrides` or `intl` message bundles — never a string literal in a widget.** *Why: this is the mechanical definition of "white-label ready."*
38. **Every color, logo, and font reference in a screen must resolve through the active `AppTheme`/`TenantConfig`, never a literal `Color(0xFF...)` or a bundled-only asset path.** *Why: same rationale as rule 10, restated for tenant-specific correctness.*
39. **Any new feature must declare, in its section of `04_FEATURE_IMPLEMENTATION_ORDER.md`, whether it is tenant-disable-able via a feature flag; if yes, its route registration and nav entry must both check that flag.** *Why: enterprise clients frequently want to license a subset of features; retrofitting flags later touches every route.*

## 9. Routing Rules

40. **Every route is registered with a named constant (never a raw string path scattered across call sites) defined once in its owning feature's `<feature>_routes.dart`.** *Why: renaming a path becomes a one-file change instead of a find-and-replace across the codebase.*
41. **Every protected route (auth-required or role-required) is enforced by the shared guard in `core/routing/`, never by an ad hoc check inside a screen's `initState`/`build`.** *Why: a screen-level check can be bypassed by a different navigation path; a router-level guard cannot.*

## 10. Process Rules

42. **`14_IMPLEMENTATION_PROGRESS.md` must be updated at the end of every milestone**, moving the milestone from ⬜/🟨 to 🟩 with a one-line completion note and date. *Why: this document is only useful as a source of truth if it is never allowed to go stale.*
43. **No milestone is started while a prior, dependency-ordered milestone is not yet 🟩 Completed**, unless the exception is explicitly documented (see the Phase 14/15 sequencing note in `03_DEVELOPMENT_PHASES.md`). *Why: out-of-order work is how partially-built, hard-to-debug features accumulate.*
44. **Any new feature, screen, or scope addition discovered mid-development must be added to `04_FEATURE_IMPLEMENTATION_ORDER.md` (and, if it changes milestone count, `03_DEVELOPMENT_PHASES.md`) before implementation starts.** *Why: prevents scope drift that silently invalidates the plan documents.*
45. **A milestone is never left in a non-compiling or non-runnable state at the end of a working session.** If a milestone must be paused mid-way, revert to the last compiling state or explicitly mark it 🟨 In Progress with a note on exact remaining work. *Why: the entire project strategy depends on every increment being shippable.*

---

## Quick Reference Checklist (paste into every PR / milestone review)

- [ ] No business logic in widgets (Rule 1)
- [ ] No direct repository/data-source access from UI (Rule 2)
- [ ] No `presentation → data` imports (Rule 3)
- [ ] No `BuildContext` in repository/usecase/bloc (Rule 4)
- [ ] No cross-feature internal imports (Rule 5)
- [ ] `presentation/domain/data` all present for the feature touched (Rule 7)
- [ ] No duplicated widget introduced (Rule 9)
- [ ] No hardcoded color/spacing/tenant branch (Rules 10–11, 37–38)
- [ ] Only `flutter_bloc` used for business state (Rules 12–13)
- [ ] Loading / Empty / Error states present for any new async screen (Rules 17–19)
- [ ] Forms validated with shared validators (Rule 20)
- [ ] Repository interface + mock implementation both present (Rules 23–24)
- [ ] `Result<Failure, T>` used, list results paginated (Rules 25–26)
- [ ] Public APIs documented (Rule 29)
- [ ] Unit tests for new use cases/repositories; `bloc_test` for new Blocs (Rules 32–33)
- [ ] Route registered via named constant + guarded if protected (Rules 40–41)
- [ ] `14_IMPLEMENTATION_PROGRESS.md` updated (Rule 42)
