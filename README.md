# White Label Commerce Platform

[![CI](https://github.com/MuneerAhamed01/E-Commerce-Multi/actions/workflows/ci.yml/badge.svg)](https://github.com/MuneerAhamed01/E-Commerce-Multi/actions/workflows/ci.yml)

Production-ready, multi-tenant, white-label e-commerce platform: Flutter Mobile + Flutter Web storefront, and a Flutter Admin Panel, built on Clean Architecture with Firebase-ready data contracts.

**Status: Phase 7 (Authentication) complete** on branch `phase/7-authentication`. Full auth journey (splash/onboarding/login/register/forgot-password/OTP), mock session persistence, and live route-guard integration for storefront + admin. See `docs/14_IMPLEMENTATION_PROGRESS.md` for live milestone status.

## Getting Started

Prerequisites (one-time, per machine):

```bash
brew install fvm            # Flutter Version Manager
dart pub global activate melos
```

Clone the repo, then from the repository root:

```bash
fvm install                 # installs the pinned Flutter SDK (see .fvmrc)
melos bootstrap             # resolves the shared pub workspace (see pubspec.yaml `workspace:`)
melos run analyze           # static analysis, every package
melos run format            # formatting check, every package
melos run test               # unit/widget tests, every package with a test/ dir
```

Run an app (always via an explicit flavor entry point - there is no bare `main.dart` - and its matching `--dart-define-from-file`, per `docs/11_ENVIRONMENT_CONFIGURATION.md` §3):

```bash
cd apps/storefront && fvm flutter run -t lib/main_dev.dart --dart-define-from-file=../../config/env/dev.env
cd apps/admin       && fvm flutter run -t lib/main_dev.dart --dart-define-from-file=../../config/env/dev.env -d chrome
```

This repository pins its Flutter/Dart SDK via [fvm](https://fvm.app/) (`.fvmrc` at the root - every package inherits it, no per-package pinning needed) and uses a single [pub workspace](https://dart.dev/tools/pub/workspaces) (`workspace:` in the root `pubspec.yaml`) for unified dependency resolution across all 26 packages/apps, orchestrated by [Melos](https://melos.invertase.dev/) (`melos:` key in the root `pubspec.yaml`) for cross-package scripts. See `docs/02_PROJECT_STRUCTURE.md` for the full monorepo layout.

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
