# Phase 15 — Orders Manual Test Cases

**Branch:** `phase/15-orders`  
**PR:** _(fill after open)_  

**Base:** `phase/14-checkout` (stacked — merge to `develop` only after Phase 14 merges **and** every case below is `Pass` / justified `N/A`).

| Field | Value |
|---|---|
| Tester | |
| Date | |
| Platform(s) | e.g. macOS storefront / iOS simulator / Chrome |
| Build / commit | `31a10c4` (or later on this branch) |
| Overall result | ⬜ Not started · 🟨 In progress · 🟩 Ready to merge |

**How to mark results**

For each case, change the result cell:

- `⬜` → pending  
- `✅ Pass`  
- `❌ Fail` — add a short note in **Notes** (what you saw)  
- `➖ N/A` — only if the step cannot apply on your platform; say why  

When you finish a batch, paste comments here or in chat (e.g. `P15-S05 Fail — …`). I will fix failures, then you re-run only the failed IDs.

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

- Mock OTP (always): `123456`  
- Catalog / cart / checkout / orders are **100% mock**.

### Demo path

1. Sign in as Noah → **Profile** → **My orders** → list of seeded orders (newest first).  
2. Open a **Placed** / **Processing** order → **Cancel order** → pick reason → confirm → status becomes Cancelled; Cancel button gone.  
3. Open a **Delivered** order (seed cycle includes delivered; or place checkout then wait — use another seed status via list) → **Request return** → status becomes Return requested.  
4. Alternate path: Cart → Checkout → Place order → confirmation → **View order** / **View all orders**.

### Policy (server-side re-validated in mock)

| Action | Allowed when |
|---|---|
| Cancel | `placed` or `processing` only |
| Request return | `delivered` only |

Ineligible attempts return `ValidationFailure` (UI snackbar / no status change).

### Seed notes

- Status cycle includes `pending`, `paid`, `shipped`, `delivered`, `cancelled`, `returnRequested`, `returned`.  
- Noah (`user_cust_02`) has multiple orders; statuses rotate across the catalog so every status appears somewhere in history for some customers.

### Deviations (documented)

| Topic | Approach |
|---|---|
| Cancel/return routes | Modal dialogs from detail (`CancelReturnDialog`); named path helpers exist but are not separate GoRoutes |
| Profile | Minimal **My orders** tile until Phase 18 |
| Pagination | History loads full customer list (no cursor pagination yet) |

### Mock call types (Dev Panel)

- `orders.create` · `orders.get` · `orders.list`
- `orders.tracking` · `orders.cancel` · `orders.return`

---

## A. Auth & entry

| ID | Scenario | Steps | Expected | Result | Notes |
|---|---|---|---|---|---|
| P15-S01 | Guest blocked | Guest → open `/orders` | Redirect to login with return-to | ⬜ | |
| P15-S02 | Profile entry | Auth → Profile → My orders | `/orders` history | ⬜ | |
| P15-S03 | Confirmation View order | Place order → View order | Detail for that order id | ⬜ | |
| P15-S04 | Confirmation View all | Place order → View all orders | History list | ⬜ | |

---

## B. Order history

| ID | Scenario | Steps | Expected | Result | Notes |
|---|---|---|---|---|---|
| P15-S05 | List loads | Noah → My orders | Tiles with number, badge, date, total | ⬜ | |
| P15-S06 | Newest first | Compare dates on list | Descending by created date | ⬜ | |
| P15-S07 | Open detail | Tap a tile | `/orders/:orderId` | ⬜ | |
| P15-S08 | Empty state | New user / clear seed if needed | Empty + Start Shopping → products | ⬜ | |
| P15-S09 | Status badges | Scan list | Token-colored badges per status (no crash) | ⬜ | |

---

## C. Order detail & tracking

| ID | Scenario | Steps | Expected | Result | Notes |
|---|---|---|---|---|---|
| P15-S10 | Header | Open any order | Number + badge + placed date | ⬜ | |
| P15-S11 | Lines & totals | Open order | Items, address, subtotal/shipping/tax/total | ⬜ | |
| P15-S12 | Timeline | Open delivered order | Chronological events ending in Delivered | ⬜ | |
| P15-S13 | Not found | Open `/orders/not-a-real-id` | Error state + retry; no crash | ⬜ | |

---

## D. Cancel / return

| ID | Scenario | Steps | Expected | Result | Notes |
|---|---|---|---|---|---|
| P15-S14 | Cancel eligible | Placed/Processing → Cancel → reason → confirm | Status Cancelled; button gone | ⬜ | |
| P15-S15 | Cancel ineligible | Shipped/Delivered detail | No Cancel button | ⬜ | |
| P15-S16 | Double cancel | Cancel once, try again | Second cancel not available / no error crash | ⬜ | |
| P15-S17 | Return eligible | Delivered → Request return → reason | Status Return requested | ⬜ | |
| P15-S18 | Return ineligible | Non-delivered detail | No Request return button | ⬜ | |
| P15-S19 | Dismiss dialog | Open cancel → Keep order | No status change | ⬜ | |

---

## E. Smoke / regression

| ID | Scenario | Steps | Expected | Result | Notes |
|---|---|---|---|---|---|
| P15-R01 | Checkout still works | Full place-order path | Confirmation + View order works | ⬜ | |
| P15-R02 | Cart still works | Add / badge | Phase 13 intact | ⬜ | |
| P15-R03 | Auth still works | Logout / login | Session OK | ⬜ | |
| P15-R04 | Catalog / home | Home + products | Still load | ⬜ | |

---

## Sign-off

| Role | Name | Date | Signature / ack |
|---|---|---|---|
| Implementer | | | |
| QA / human gate | | | |

**Merge rule:** Do **not** merge this PR into `develop` until Phase 14 is on `develop` and Overall result is 🟩 with all applicable cases Pass/N/A.
