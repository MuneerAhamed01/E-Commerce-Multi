# admin

Admin Panel Flutter app (web-first, responsive to tablet/desktop) for the
White Label Commerce Platform. This is a thin app shell - business logic and
UI live in `packages/features/*` (see `docs/02_PROJECT_STRUCTURE.md` §3).

## Running

```bash
fvm flutter run -t lib/main_dev.dart -d chrome        # dev flavor
fvm flutter run -t lib/main_staging.dart -d chrome    # staging flavor
fvm flutter run -t lib/main_prod.dart -d chrome       # prod flavor
```

Currently a Phase 1 (Project Foundation) placeholder - see
`docs/03_DEVELOPMENT_PHASES.md`.
