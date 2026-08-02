# admin

Admin Panel Flutter app (web-first, responsive to tablet/desktop) for the
White Label Commerce Platform. This is a thin app shell - business logic and
UI live in `packages/features/*` (see `docs/02_PROJECT_STRUCTURE.md` §3).

## Running

Each flavor needs its matching `--dart-define-from-file` (see
`docs/11_ENVIRONMENT_CONFIGURATION.md` §3):

```bash
fvm flutter run -t lib/main_dev.dart     --dart-define-from-file=../../config/env/dev.env     -d chrome
fvm flutter run -t lib/main_staging.dart --dart-define-from-file=../../config/env/staging.env -d chrome
fvm flutter run -t lib/main_prod.dart    --dart-define-from-file=../../config/env/prod.env    -d chrome --release
```

`assets/tenants` is a symlink to the repo-root `config/tenants/` (single
source of truth for tenant JSON files - see `bootstrap.dart` and
`docs/11_ENVIRONMENT_CONFIGURATION.md` §6); don't replace it with a real
directory.

Phase 5 routing is live: `lib/app/app_router.dart` owns the `go_router`
tree (side-nav shell + login + RBAC stubs + guards). Feature screens are
still placeholders until their owning feature packages land — see
`docs/03_DEVELOPMENT_PHASES.md`.
