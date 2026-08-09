# cart

Hold items intended for purchase; compute authoritative pricing; apply promo
codes.

See `docs/04_FEATURE_IMPLEMENTATION_ORDER.md` §7 and Phase 13 of
`docs/03_DEVELOPMENT_PHASES.md`.

## Circular dependency

`cart` depends on `products` for price/stock via `GetProductDetail`.
`products` does **not** depend on `cart`. The storefront wires add-to-cart
through an optional `onAddToCart` callback on `ProductDetailScreen`.

## Marketing deviation

Promo codes are validated **locally inside cart** (`CartPromoCatalog`) until
Phase 25 Marketing owns coupons / `ValidateCoupon`. Seeded QA codes:

| Code | Behavior |
|---|---|
| `SAVE10` | 10% off |
| `SAVE5` | $5.00 fixed off |
| `EXPIRED` | Always expired |
| `NOSPEND` | Requires $100.00 min spend |
| `INVALID` | Rejected as invalid |

**Policy:** single promo only (applying a new code replaces the previous).

## Run (storefront)

```bash
cd apps/storefront
fvm flutter run -t lib/main_dev.dart \
  --dart-define-from-file=../../config/env/dev.env
```

## Demo path

1. Open any product detail → **Add to cart** → snackbar with **View cart**.
2. Shell cart badge (top bar / nav) → `/cart`.
3. Adjust quantity, apply `SAVE10`, tap Checkout → `/checkout/address` (storefront
   wires navigation; cart package has no checkout dependency).
4. Empty cart → **Start Shopping** → `/products`.
5. Kill/relaunch app — cart persists (SharedPreferences `cart.<ownerId>`).

## Mock call types (Dev Panel)

- `cart.get` · `cart.add` · `cart.update` · `cart.remove`
- `cart.clear` · `cart.applyPromo` · `cart.removePromo` · `cart.merge`

## Persistence

Per-owner SharedPreferences key `cart.<ownerId>` (`guest` when logged out).
Survives app restart. Guest cart merges into the user cart on login.

## Tests

```bash
cd packages/features/cart
fvm flutter test
```
