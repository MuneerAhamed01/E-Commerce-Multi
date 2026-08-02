# products

Core catalog: browse, view detail, read/write reviews. Domain is reused by Admin Catalog.

See `docs/04_FEATURE_IMPLEMENTATION_ORDER.md` §3 and Phase 9 of
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
2. Home → **View all** (featured products) → `/products`
3. Tap a product → `/products/:productId`
4. Select variants (price/stock update); multi-variant demos on ids ending in `0`/`5`
5. Submit a review while signed in (guests are redirected to Login with return URL)

## Mock call types (Dev Panel)

- `products.list`
- `products.detail`
- `products.related`
- `products.reviews`
- `products.submitReview`

## Tests

```bash
cd packages/features/products
fvm flutter test
```
