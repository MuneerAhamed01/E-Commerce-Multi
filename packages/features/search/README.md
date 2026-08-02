# search

Query-driven product discovery with filters and sort, across the full catalog.

See `docs/04_FEATURE_IMPLEMENTATION_ORDER.md` §5 and Phase 11 of
`docs/03_DEVELOPMENT_PHASES.md`.

## Run (storefront)

```bash
cd apps/storefront
fvm flutter run -t lib/main_dev.dart \
  --dart-define-from-file=../../config/env/dev.env
```

## Demo path

1. Login (optional for browsing if guest browsing is enabled):
   - Customer: `noah.patel02@example.com` / `Password123!`
2. Bottom nav **Search** → `/search` (entry: recent/trending + suggestions)
3. Type a term (suggestions debounce ≥300ms via `AppSearchBar`) → submit
   or tap a suggestion → `/search/results?q=…`
4. Apply Filter / Sort sheets; clear filters from the zero-results empty state
5. Tap a result card → `/products/:productId`

## Mock call types (Dev Panel)

- `search.products`
- `search.suggestions`
- `search.facets`

## Filter semantics

All active `SearchFilter` fields are **AND**ed (category + price range +
min rating + in-stock). Debounce is presentation-only (`AppSearchBar`).

## Tests

```bash
cd packages/features/search
fvm flutter test
```
