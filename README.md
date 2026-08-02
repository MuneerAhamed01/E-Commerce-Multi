# White Label Commerce Platform

[![CI](https://github.com/MuneerAhamed01/E-Commerce-Multi/actions/workflows/ci.yml/badge.svg)](https://github.com/MuneerAhamed01/E-Commerce-Multi/actions/workflows/ci.yml)

Production-ready, multi-tenant, white-label e-commerce platform: Flutter Mobile + Flutter Web storefront, and a Flutter Admin Panel, built on Clean Architecture with Firebase-ready data contracts.

**Status: Phase 11 (Search) complete** on branch `phase/11-search` (stacked on Phase 10). Storefront search entry + results with mock catalog matching, filters/sort (AND), recent searches (SharedPreferences), suggestions debounced via `AppSearchBar`. Merge to `develop` only after Phase 10 merges and Phase 11 manual QA Pass. See `docs/14_IMPLEMENTATION_PROGRESS.md` for live milestone status.

## Getting Started — how to run

### 1. Prerequisites (one-time)

```bash
brew install fvm                 # Flutter Version Manager
dart pub global activate melos   # monorepo scripts
```

### 2. Clone & bootstrap

```bash
git clone https://github.com/MuneerAhamed01/E-Commerce-Multi.git
cd E-Commerce-Multi

fvm install          # installs pinned Flutter (see .fvmrc — currently 3.44.3)
melos bootstrap      # resolves the pub workspace (root pubspec.yaml `workspace:`)
```

Always prefix Flutter/Dart with `fvm` (e.g. `fvm flutter`, `fvm dart`).

### 3. Run the Storefront (customer app)

From the **repo root**:

```bash
cd apps/storefront
fvm flutter run -t lib/main_dev.dart \
  --dart-define-from-file=../../config/env/dev.env
```

- Pick a device when prompted (iOS Simulator, Android emulator, Chrome, macOS, etc.).
- There is **no** bare `main.dart` — always use a flavor entry (`main_dev.dart` / `main_staging.dart` / `main_prod.dart`) plus the matching env file under `config/env/`.

Useful variants:

```bash
# Explicit device
fvm flutter run -t lib/main_dev.dart \
  --dart-define-from-file=../../config/env/dev.env \
  -d chrome

# List devices
fvm flutter devices
```

### 4. Run the Admin panel

```bash
cd apps/admin
fvm flutter run -t lib/main_dev.dart \
  --dart-define-from-file=../../config/env/dev.env \
  -d chrome
```

Admin is primarily a **web** surface; Chrome/macOS/Windows/Linux are supported.

### 5. Demo login (mock auth) → Home / Dashboard

Auth and catalog feeds are **mock** (not Firebase). Use:

| App | Email | Password | Lands on |
|---|---|---|---|
| Storefront | `noah.patel02@example.com` | `Password123!` | **Home** (banners + featured rows) |
| Admin | `admin@example.com` | `Password123!` | **Dashboard** (KPI cards + sales trend) |

Mock OTP: `123456`. Manual QA: [`docs/manual_qa/PHASE_08_DASHBOARD_HOME.md`](docs/manual_qa/PHASE_08_DASHBOARD_HOME.md) (Phase 7 auth: [`PHASE_07_AUTHENTICATION.md`](docs/manual_qa/PHASE_07_AUTHENTICATION.md)).

### 6. Quality checks (CI mirrors these)

From the repo root:

```bash
melos run format     # or: fvm dart run melos run format
melos run analyze
melos run test
```

### 7. Manual QA gate (feature phases)

From Phase 7 onward, each phase has a checklist under [`docs/manual_qa/`](docs/manual_qa/). **Merge into `develop` only after every applicable case is marked Pass.**

This repository pins its Flutter/Dart SDK via [fvm](https://fvm.app/) (`.fvmrc` at the root), uses a single [pub workspace](https://dart.dev/tools/pub/workspaces) (`workspace:` in the root `pubspec.yaml`), and [Melos](https://melos.invertase.dev/) (`melos:` key in root `pubspec.yaml`) for cross-package scripts. See `docs/02_PROJECT_STRUCTURE.md` for the full monorepo layout.

## Start Here

Read the full planning package in [`docs/`](docs/), starting with [`docs/01_IMPLEMENTATION_PLAN.md`](docs/01_IMPLEMENTATION_PLAN.md).

| Doc | Purpose |
|---|---|
| [01_IMPLEMENTATION_PLAN.md](docs/01_IMPLEMENTATION_PLAN.md) | Vision, scope, milestones index, risks, success criteria |
| [02_PROJECT_STRUCTURE.md](docs/02_PROJECT_STRUCTURE.md) | Full monorepo folder structure and naming conventions |
| [03_DEVELOPMENT_PHASES.md](docs/03_DEVELOPMENT_PHASES.md) | 29 phases broken into 2–6 hour milestones |
| [04_FEATURE_IMPLEMENTATION_ORDER.md](docs/04_FEATURE_IMPLEMENTATION_ORDER.md) | Every feature, fully specified, in dependency order |
| [05_ARCHITECTURE_GUIDELINES.md](docs/05_ARCHITECTURE_GUIDELINES.md) | Clean Architecture rules and future backend integration strategy |
| [06_DEVELOPMENT_RULES.md](docs/06_DEVELOPMENT_RULES.md) | Mandatory rules for every engineer/AI agent |
| [07_SCREEN_CATALOG.md](docs/07_SCREEN_CATALOG.md) | Every screen, fully specified |
| [08_COMPONENT_LIBRARY.md](docs/08_COMPONENT_LIBRARY.md) | Every reusable UI component |
| [09_ROUTING_PLAN.md](docs/09_ROUTING_PLAN.md) | Complete `go_router` routing strategy |
| [10_DATA_FLOW.md](docs/10_DATA_FLOW.md) | Mock → Domain → Bloc → UI data flow and future Firebase swap |
| [11_ENVIRONMENT_CONFIGURATION.md](docs/11_ENVIRONMENT_CONFIGURATION.md) | Environments, flavors, secrets, feature flags |
| [12_MANUAL_TEST_PLAN.md](docs/12_MANUAL_TEST_PLAN.md) | Full manual QA checklist |
| [13_CLIENT_DELIVERY_CHECKLIST.md](docs/13_CLIENT_DELIVERY_CHECKLIST.md) | Everything required before client handoff |
| [14_IMPLEMENTATION_PROGRESS.md](docs/14_IMPLEMENTATION_PROGRESS.md) | Live status tracker (⬜ / 🟨 / 🟩) — kept up to date during development |

## Development Process

Implementation proceeds strictly in the order defined in `docs/03_DEVELOPMENT_PHASES.md`, in small (2-6 hour) reviewable milestones. No feature's widgets, blocs, or repositories are written ahead of its own phase. `docs/14_IMPLEMENTATION_PROGRESS.md` is updated at the end of every milestone and is the source of truth for what has actually been built.

## Git branching (dev vs production)

| Branch | Role |
|---|---|
| `main` | **Production** — always releasable. Only receives merges from `develop` after a phase (or hotfix) is verified. |
| `develop` | **Integration / day-to-day development**. Default base for all phase work. |
| `phase/<N>-<short-name>` | **One branch per phase** (e.g. `phase/5-routing-foundation`). Branched from `develop`, merged back via PR when the phase is complete. |

**Workflow for every new phase:**

```bash
git checkout develop
git pull origin develop
git checkout -b phase/5-routing-foundation
# ... implement the phase ...
git push -u origin HEAD
# Open a PR: phase/5-routing-foundation → develop
# After merge + smoke check, open/merge develop → main for production
```

**Rules:**
- Do not commit directly to `main`.
- Do not put secrets in git: only `config/env/{dev,staging,prod}.env` (non-secret) are committed. Real secrets use `*.secret.env` (gitignored) from the `*.secret.env.example` templates. Firebase credentials under `config/firebase/` are gitignored except `*.example.*`.
- CI runs secret scanning (Gitleaks) before format/analyze/test on `main`, `develop`, and `phase/**`.
- Prefer PRs into `develop`; keep commits focused and free of credentials, keystores, and local IDE junk.
- **Feature phases (Phase 7+):** do not merge into `develop` until the phase manual QA file in `docs/manual_qa/` is fully Pass (CI green alone is not enough).
