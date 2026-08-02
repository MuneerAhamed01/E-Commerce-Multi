# categories

Structured, hierarchical browsing entry point into Products.

See `docs/04_FEATURE_IMPLEMENTATION_ORDER.md` §4 and Phase 10 of
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
2. Bottom nav **Categories** → `/categories` (top-level grid)
3. Tap a tile → `/categories/:categoryId` (breadcrumb + subcategory chips +
   filtered product list)
4. Drill via subcategory chips or breadcrumb; product tap → Product Detail
5. Home featured category taps deep-link to `/categories/:categoryId`

## Mock call types (Dev Panel)

- `categories.tree`
- `categories.detail`

## Tests

```bash
cd packages/features/categories
fvm flutter test
```
