# storefront

Customer-facing Flutter app (Mobile: iOS/Android + Web) for the White Label
Commerce Platform. This is a thin app shell - business logic and UI live in
`packages/features/*` (see `docs/02_PROJECT_STRUCTURE.md` §3).

## Running

```bash
fvm flutter run -t lib/main_dev.dart        # dev flavor
fvm flutter run -t lib/main_staging.dart    # staging flavor
fvm flutter run -t lib/main_prod.dart       # prod flavor
```

Currently a Phase 1 (Project Foundation) placeholder - see
`docs/03_DEVELOPMENT_PHASES.md`.
