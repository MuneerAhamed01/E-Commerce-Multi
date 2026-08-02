# Phase 9 — Products Manual Test Cases

**Branch:** `phase/9-products`  
**PR:** [https://github.com/MuneerAhamed01/E-Commerce-Multi/pull/7](https://github.com/MuneerAhamed01/E-Commerce-Multi/pull/7)  

**Base:** `phase/8-dashboard-home` (stacked — merge to `develop` only after Phase 8 merges **and** every case below is `Pass` / justified `N/A`).

| Field | Value |
|---|---|
| Tester | |
| Date | |
| Platform(s) | e.g. macOS storefront / iOS simulator / Chrome |
| Build / commit | `31a8150` (or later on this branch) |
| Overall result | ⬜ Not started · 🟨 In progress · 🟩 Ready to merge |

**How to mark results**

For each case, change the result cell:

- `⬜` → pending  
- `✅ Pass`  
- `❌ Fail` — add a short note in **Notes** (what you saw)  
- `➖ N/A` — only if the step cannot apply on your platform; say why  

When you finish a batch, paste comments here or in chat (e.g. `P9-S05 Fail — …`). I will fix failures, then you re-run only the failed IDs.

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
| Admin | `admin@example.com` | `Password123!` |

- Mock OTP (always): `123456`  
- Catalog is **100% mock** (`MockSeedStore` 192 products + synthesized variants/reviews). No Firebase.

### Demo path (guest OK if `allowGuestBrowsing`)

1. Optional: login as customer above.  
2. Home → **View all** → `/products` (paginated grid).  
3. Tap a card → `/products/:productId`.  
4. Change variants (price/stock/image update). Multi-variant demos: ids ending in `0` or `5`.  
5. Reviews: guest → **Sign in to review** → login → return to detail → submit → list updates.

### Mock call types (Dev Panel)

- `products.list` · `products.detail` · `products.related` · `products.reviews` · `products.submitReview`

---

## A. Product listing

| ID | Scenario | Steps | Expected | Result | Notes |
|---|---|---|---|---|---|
| P9-S01 | Open catalog | Home → **View all** (or go `/products`) | Product grid loads (skeleton may flash); ≥1 page of cards with prices | ⬜ | |
| P9-S02 | Infinite scroll | Scroll near bottom of list | Next page loads; no duplicates; eventually “End of catalog” | ⬜ | |
| P9-S03 | Open detail from list | Tap a product card | Navigates to `/products/:id` with real detail (not placeholder) | ⬜ | |
| P9-S04 | Category query filter | Open `/products?categoryId=cat_apparel` | List scoped to that category (header shows category id) | ⬜ | |
| P9-S05 | Empty category | Open `/products?categoryId=cat_does_not_exist` | Empty state (“No products found”) | ⬜ | |
| P9-S06 | List failure + retry | Dev Panel → force `products.list` → open/refresh `/products` | Error + Retry; clear failure → Retry succeeds | ⬜ | |

---

## B. Product detail & variants

| ID | Scenario | Steps | Expected | Result | Notes |
|---|---|---|---|---|---|
| P9-S07 | Featured product tap | Home → tap featured product | Real Product Detail (name, price, description, variants) | ⬜ | |
| P9-S08 | Variant changes price/stock | On a multi-variant product (id ends `0`/`5`), select another option | Displayed price and stock update; gallery highlight may change | ⬜ | |
| P9-S09 | OOS variant selectable | Select an option labeled `(OOS)` | Still selectable; Add to cart shows out-of-stock messaging (snackbar / blocked) | ⬜ | |
| P9-S10 | In-stock Add to cart | Select in-stock variant → Add to cart | Snackbar “Coming soon — cart is not available yet” (Cart phase later) | ⬜ | |
| P9-S11 | Related products | Scroll to Related → tap a card | Navigates to that product’s detail | ⬜ | |
| P9-S12 | Missing product | Open `/products/prod_does_not_exist` | Error / not-found state with Retry | ⬜ | |
| P9-S13 | Detail failure + retry | Force `products.detail` → open a valid product | Error + Retry recovers after clearing failure | ⬜ | |

---

## C. Reviews

| ID | Scenario | Steps | Expected | Result | Notes |
|---|---|---|---|---|---|
| P9-S14 | Reviews visible | Open any product with seeded reviews | Rating summary + review list render | ⬜ | |
| P9-S15 | Guest must sign in | Logged out → tap **Sign in to review** | Goes to Login with `?redirect=` back to this product | ⬜ | |
| P9-S16 | Return after login | Complete P9-S15 → login as customer | Lands back on product detail | ⬜ | |
| P9-S17 | Submit review | Signed in → write title/body → Submit | Snackbar success; new review appears at top without restart | ⬜ | |
| P9-S18 | Reset mock data | Submit a review → Dev Panel → Reset mock data → reopen reviews | Submitted review gone; seed reviews restored | ⬜ | |

---

## D. Smoke / regression

| ID | Scenario | Steps | Expected | Result | Notes |
|---|---|---|---|---|---|
| P9-R01 | Home still works | After catalog browsing, Home tab | Banners / featured still load | ⬜ | |
| P9-R02 | Auth still works | Logout / login | Lands on Home; session intact | ⬜ | |
| P9-R03 | Shell tabs | Categories / Search / Profile tabs | No crash; placeholders OK | ⬜ | |

---

## Sign-off

| Role | Name | Date | Signature / ack |
|---|---|---|---|
| Implementer | | | |
| QA / human gate | | | |

**Merge rule:** Do **not** merge this PR into `develop` until Phase 8 is on `develop` and Overall result is 🟩 with all applicable cases Pass/N/A.
