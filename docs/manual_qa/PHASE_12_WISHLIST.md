# Phase 12 — Wishlist Manual Test Cases

**Branch:** `phase/12-wishlist`  
**PR:** _(filled after open)_  

**Base:** `phase/11-search` (stacked — merge to `develop` only after Phase 11 merges **and** every case below is `Pass` / justified `N/A`).

| Field | Value |
|---|---|
| Tester | |
| Date | |
| Platform(s) | e.g. macOS storefront / iOS simulator / Chrome |
| Build / commit | `6296710` (or later on this branch) |
| Overall result | ⬜ Not started · 🟨 In progress · 🟩 Ready to merge |

**How to mark results**

For each case, change the result cell:

- `⬜` → pending  
- `✅ Pass`  
- `❌ Fail` — add a short note in **Notes** (what you saw)  
- `➖ N/A` — only if the step cannot apply on your platform; say why  

When you finish a batch, paste comments here or in chat (e.g. `P12-S05 Fail — …`). I will fix failures, then you re-run only the failed IDs.

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
| Customer (pre-seeded wishlist) | `noah.patel02@example.com` | `Password123!` |
| Customer (empty wishlist) | `mia.garcia03@example.com` | `Password123!` |
| Admin | `admin@example.com` | `Password123!` |

- Mock OTP (always): `123456`  
- Catalog is **100% mock**. Wishlist persists per user in SharedPreferences (`wishlist.<userId>`).
- Demo customer `user_cust_02` is pre-seeded with `prod_001`, `prod_007`, `prod_014`.

### Demo path

1. Login as Noah (`noah.patel02@example.com`).  
2. Bottom nav **Wishlist** → `/wishlist` (seeded grid).  
3. Open `/products` or a product detail → heart toggle adds/removes.  
4. As guest, tap heart → Login with return-to; after login pending add completes.  
5. Empty wishlist → **Browse Products** → `/products`.

### Mock call types (Dev Panel)

- `wishlist.get` · `wishlist.add` · `wishlist.remove` · `wishlist.contains`

### Circular-dep note

`wishlist` → `products` for display. `products` does **not** depend on `wishlist`. Storefront composes `WishlistToggleButton` via optional `wishlistAction` / `wishlistActionBuilder` slots.

---

## A. Wishlist screen

| ID | Scenario | Steps | Expected | Result | Notes |
|---|---|---|---|---|---|
| P12-S01 | Seeded load | Login as Noah → Wishlist tab | Grid shows 3 seeded products | ⬜ | |
| P12-S02 | Open detail | Tap a wishlisted card | Navigates to `/products/:id` | ⬜ | |
| P12-S03 | Remove from grid | Tap heart/remove on a card | Item disappears; count decreases | ⬜ | |
| P12-S04 | Empty state | Login as Mia → Wishlist | Empty copy + **Browse Products** CTA | ⬜ | |
| P12-S05 | Browse CTA | From empty → **Browse Products** | Lands on `/products` | ⬜ | |
| P12-S06 | Guest guard | Logged out → open Wishlist tab / `/wishlist` | Redirect to Login with `redirect=/wishlist` | ⬜ | |
| P12-S07 | Failure + retry | Dev Panel force `wishlist.get` → open Wishlist | Error + Retry; clear failure → Retry succeeds | ⬜ | |

---

## B. Toggle sync (list / detail / wishlist)

| ID | Scenario | Steps | Expected | Result | Notes |
|---|---|---|---|---|---|
| P12-S08 | Add from listing | Login → `/products` → heart on a card | Heart fills; item appears on Wishlist screen | ⬜ | |
| P12-S09 | Add from detail | Open product detail → heart | Heart fills; Wishlist screen shows it | ⬜ | |
| P12-S10 | Remove from detail | On wishlisted detail → heart | Heart clears; removed from Wishlist screen | ⬜ | |
| P12-S11 | Instant sync | Toggle on detail, switch to Wishlist tab (no restart) | Membership matches immediately | ⬜ | |
| P12-S12 | Persist restart | Add item → kill/relaunch app → login same user | Wishlist still contains the item | ⬜ | |
| P12-S13 | Guest toggle | Logged out on detail → heart | Goes to Login; after login item is wishlisted (pending flush) | ⬜ | |
| P12-S14 | Related card toggle | Detail related row heart (if shown) | Toggles same as listing | ⬜ | |

---

## C. Smoke / regression

| ID | Scenario | Steps | Expected | Result | Notes |
|---|---|---|---|---|---|
| P12-R01 | Search still works | Open Search entry/results | No crash; results load | ⬜ | |
| P12-R02 | Categories still works | Categories browse/detail | Grid/detail still load | ⬜ | |
| P12-R03 | Products still works | `/products` + detail | Listing/detail still load | ⬜ | |
| P12-R04 | Home still works | Home tab | Banners / featured still load | ⬜ | |
| P12-R05 | Auth still works | Logout / login | Lands on Home; session intact | ⬜ | |
| P12-R06 | Feature flag | (if toggling wishlist flag off is practical) | Wishlist nav/route hidden or gated | ⬜ | |

---

## Sign-off

| Role | Name | Date | Signature / ack |
|---|---|---|---|
| Implementer | | | |
| QA / human gate | | | |

**Merge rule:** Do **not** merge this PR into `develop` until Phase 11 is on `develop` and Overall result is 🟩 with all applicable cases Pass/N/A.
