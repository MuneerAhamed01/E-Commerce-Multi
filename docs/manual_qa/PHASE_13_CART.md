# Phase 13 — Cart Manual Test Cases

**Branch:** `phase/13-cart`  
**PR:** [https://github.com/MuneerAhamed01/E-Commerce-Multi/pull/11](https://github.com/MuneerAhamed01/E-Commerce-Multi/pull/11)  

**Base:** `phase/12-wishlist` (stacked — merge to `develop` only after Phase 12 merges **and** every case below is `Pass` / justified `N/A`).

| Field | Value |
|---|---|
| Tester | |
| Date | |
| Platform(s) | e.g. macOS storefront / iOS simulator / Chrome |
| Build / commit | `c487059` (or later on this branch) |
| Overall result | ⬜ Not started · 🟨 In progress · 🟩 Ready to merge |

**How to mark results**

For each case, change the result cell:

- `⬜` → pending  
- `✅ Pass`  
- `❌ Fail` — add a short note in **Notes** (what you saw)  
- `➖ N/A` — only if the step cannot apply on your platform; say why  

When you finish a batch, paste comments here or in chat (e.g. `P13-S05 Fail — …`). I will fix failures, then you re-run only the failed IDs.

---

## Prerequisites

### Run storefront (dev)

```bash
cd /Users/muneerahamed/Documents/E-Com-Buisness
fvm install
melos bootstrap   # first time / after pubspec changes

cd apps/storefront
fvm flutter run -t lib/main_dev.dart \
  --dart-define-from-file=../../config/env/dev.env
```

### Demo credentials (mock — not Firebase)

| Role | Email | Password |
|---|---|---|
| Customer | `noah.patel02@example.com` | `Password123!` |
| Customer (alt) | `mia.garcia03@example.com` | `Password123!` |
| Admin | `admin@example.com` | `Password123!` |

- Mock OTP (always): `123456`  
- Catalog is **100% mock**. Cart persists per owner in SharedPreferences (`cart.<ownerId>`; guest → `cart.guest`).
- Cart is **empty by default**.

### Seeded promo codes (local cart mock — Marketing deviation)

| Code | Expected |
|---|---|
| `SAVE10` | 10% off |
| `SAVE5` | $5.00 fixed off |
| `EXPIRED` | Inline error — expired |
| `NOSPEND` | Inline error — min spend $100 not met (unless cart is huge) |
| `INVALID` | Inline error — invalid |

**Policy:** single promo only (applying a new code replaces the previous after validation).

### Demo path

1. Open `/products` → product detail → **Add to cart** → snackbar + **View cart**.  
2. Bottom nav **Cart** (badge shows sum of quantities) → `/cart`.  
3. Change quantity, apply `SAVE10`, tap **Checkout** → soft “Phase 14” snackbar.  
4. Empty cart → **Start Shopping** → `/products`.  
5. Kill/relaunch — cart still present for same guest/user.

### Mock call types (Dev Panel)

- `cart.get` · `cart.add` · `cart.update` · `cart.remove`
- `cart.clear` · `cart.applyPromo` · `cart.removePromo` · `cart.merge`

### Circular-dep note

`cart` → `products` for price/stock (`GetProductDetail`). `products` does **not** depend on `cart`. Storefront composes add-to-cart via optional `onAddToCart` on product detail.

---

## A. Cart screen & pricing

| ID | Scenario | Steps | Expected | Result | Notes |
|---|---|---|---|---|---|
| P13-S01 | Empty by default | Open Cart tab as guest | Empty copy + **Start Shopping** CTA | ⬜ | |
| P13-S02 | Browse CTA | From empty → **Start Shopping** | Lands on `/products` | ⬜ | |
| P13-S03 | Add from detail | Product detail → **Add to cart** | Snackbar success; badge increments | ⬜ | |
| P13-S04 | View cart action | Snackbar **View cart** | Opens `/cart` with the line | ⬜ | |
| P13-S05 | Quantity update | Stepper + / − (respects stock max) | Totals update; badge matches sum of qtys | ⬜ | |
| P13-S06 | Remove last item | Remove only line | Empty state returns | ⬜ | |
| P13-S07 | Clear cart | Multi-item → **Clear** | Empty cart | ⬜ | |
| P13-S08 | Promo SAVE10 | Non-empty cart → apply `SAVE10` | Discount 10%; total updates | ⬜ | |
| P13-S09 | Promo SAVE5 | Apply `SAVE5` | $5 fixed off (clamped to subtotal) | ⬜ | |
| P13-S10 | Promo INVALID | Apply `INVALID` | Inline promo error (not generic failure) | ⬜ | |
| P13-S11 | Promo EXPIRED | Apply `EXPIRED` | Inline “expired” error | ⬜ | |
| P13-S12 | Promo NOSPEND | Small cart → `NOSPEND` | Inline min-spend error | ⬜ | |
| P13-S13 | Single promo | Apply `SAVE10` then `SAVE5` | Only one applied; totals use latest valid | ⬜ | |
| P13-S14 | Remove promo | Applied code → remove | Discount cleared | ⬜ | |
| P13-S15 | Checkout soft CTA | Non-empty → **Checkout** | Snackbar “Checkout coming in Phase 14” | ⬜ | |
| P13-S16 | Persist restart | Add items → kill/relaunch | Same cart restored | ⬜ | |
| P13-S17 | Failure + retry | Dev Panel force `cart.get` → open Cart | Error + Retry; clear failure → succeeds | ⬜ | |

---

## B. Global badge

| ID | Scenario | Steps | Expected | Result | Notes |
|---|---|---|---|---|---|
| P13-S18 | Badge live update | Add/update qty from detail / cart | Bottom-nav Cart badge = sum of quantities | ⬜ | |
| P13-S19 | Badge tap | Tap Cart nav item | `/cart` selected | ⬜ | |
| P13-S20 | Badge clears | Empty cart | Badge hidden / zero | ⬜ | |

---

## C. Smoke / regression

| ID | Scenario | Steps | Expected | Result | Notes |
|---|---|---|---|---|---|
| P13-R01 | Wishlist still works | Wishlist tab / toggles | No crash; membership syncs | ⬜ | |
| P13-R02 | Search still works | Search entry/results | No crash; results load | ⬜ | |
| P13-R03 | Categories still works | Categories browse/detail | Grid/detail still load | ⬜ | |
| P13-R04 | Products still works | `/products` + detail | Listing/detail still load | ⬜ | |
| P13-R05 | Home still works | Home tab | Banners / featured still load | ⬜ | |
| P13-R06 | Auth still works | Logout / login | Session intact; guest cart merges on login | ⬜ | |

---

## Sign-off

| Role | Name | Date | Signature / ack |
|---|---|---|---|
| Implementer | | | |
| QA / human gate | | | |

**Merge rule:** Do **not** merge this PR into `develop` until Phase 12 is on `develop` and Overall result is 🟩 with all applicable cases Pass/N/A.
