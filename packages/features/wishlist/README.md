# wishlist

Let authenticated users bookmark products for later.

See `docs/04_FEATURE_IMPLEMENTATION_ORDER.md` §6 and Phase 12 of
`docs/03_DEVELOPMENT_PHASES.md`.

## Circular dependency

`wishlist` depends on `products` for catalog [Product] display. `products`
does **not** depend on `wishlist`. The storefront composes
[WishlistToggleButton] into product list/detail via optional
`wishlistAction` / `wishlistActionBuilder` slots.

## Run (storefront)

```bash
cd apps/storefront
fvm flutter run -t lib/main_dev.dart \
  --dart-define-from-file=../../config/env/dev.env
```

## Demo path

1. Login as customer: `noah.patel02@example.com` / `Password123!`
   (`user_cust_02` is pre-seeded with a few wishlist items).
2. Bottom nav **Wishlist** → `/wishlist` (seeded grid).
3. Open `/products` or a product detail → heart toggle adds/removes.
4. Guest tap on heart → Login with return-to; after login the pending
   add completes.
5. Empty wishlist → **Browse Products** CTA → `/products`.

## Mock call types (Dev Panel)

- `wishlist.get`
- `wishlist.add`
- `wishlist.remove`
- `wishlist.contains`

## Persistence

Per-user SharedPreferences key `wishlist.<userId>`. Survives app restart.
Developer Panel **Reset mock data** restores the demo seed for
`user_cust_02` and clears other users.

## Tests

```bash
cd packages/features/wishlist
fvm flutter test
```
