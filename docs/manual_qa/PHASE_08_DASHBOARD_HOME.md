# Phase 8 — Dashboard / Home Manual Test Cases

**Branch:** `phase/8-dashboard-home`  
**PR:** _(add after open)_  
**Gate:** Merge into `develop` only when **every** case below is `Pass` (or explicitly `N/A` with reason).

| Field | Value |
|---|---|
| Tester | |
| Date | |
| Platform(s) | e.g. macOS storefront / Chrome admin / iOS simulator |
| Build / commit | `e55d41e` |
| Overall result | ⬜ Not started · 🟨 In progress · 🟩 Ready to merge |

**How to mark results**

For each case, change the result cell:

- `⬜` → pending  
- `✅ Pass`  
- `❌ Fail` — add a short note in **Notes** (what you saw)  
- `➖ N/A` — only if the step cannot apply on your platform; say why  

When you finish a batch, paste comments here or in chat (e.g. `P8-S03 Fail — …`). I will fix failures, then you re-run only the failed IDs.

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

### Run admin (dev, Web recommended)

```bash
cd /Users/muneerahamed/Documents/E-Com-Buisness/apps/admin
fvm flutter run -t lib/main_dev.dart \
  --dart-define-from-file=../../config/env/dev.env \
  -d chrome
```

### Demo credentials (mock — not Firebase)

| Role | Email | Password |
|---|---|---|
| Customer | `noah.patel02@example.com` | `Password123!` |
| Admin | `admin@example.com` | `Password123!` |
| Support | `support@example.com` | `Password123!` |

- Mock OTP (always): `123456`  
- Home/Dashboard data is **100% mock** (`MockSeedStore` + dashboard banner seed). No Firebase calls.

### Phase 8 deviation (for testers)

Featured products/categories come from shared seed fixtures inside the
`dashboard` package (products/categories/marketing packages are still stubs).
Banners are a small hardcoded seed list in `dashboard`. Admin KPIs are
aggregated from seed orders/products.

---

## A. Storefront — Home load & content

| ID | Scenario | Steps | Expected | Result | Notes |
|---|---|---|---|---|---|
| P8-S01 | Home after login | Login as customer → land on Home | **Home** shows (not placeholder title-only page); skeleton may flash briefly | ⬜ | |
| P8-S02 | Banners visible | On Home, scroll if needed | Banner carousel with ≥1 promotional slide | ⬜ | |
| P8-S03 | Featured categories | On Home | “Shop by category” row with top-level categories | ⬜ | |
| P8-S04 | Featured products | On Home | “Featured products” row with prices | ⬜ | |
| P8-S05 | Pull to refresh | Pull down on Home | Reloads; content returns (may show skeleton briefly) | ⬜ | |
| P8-S06 | Category tap | Tap a featured category | Navigates to **Categories** placeholder (`/categories`) | ⬜ | |
| P8-S07 | Product tap | Tap a featured product | Navigates to **Product** placeholder (`/products/:id`) with product id subtitle | ⬜ | |
| P8-S08 | Banner tap (category) | Tap a banner that targets a category | Goes to Categories (or product stub if banner targets product) | ⬜ | |

---

## B. Storefront — Home error / empty / guest

| ID | Scenario | Steps | Expected | Result | Notes |
|---|---|---|---|---|---|
| P8-S09 | Simulated home failure | Open Dev Panel → force failure for `dashboard.homeFeed` → reopen/refresh Home | **Error** state with Retry | ⬜ | |
| P8-S10 | Retry after failure | From P8-S09, clear forced failure → tap Retry | Home loads successfully | ⬜ | |
| P8-S11 | Guest browsing (if enabled) | With tenant `allowGuestBrowsing: true`, open `/home` logged out | Home content still loads (guard allows public home) | ⬜ | |
| P8-S12 | Guest blocked (if disabled) | With `allowGuestBrowsing: false`, open `/home` logged out | Redirected to Login | ⬜ | |

---

## C. Admin — Dashboard KPIs

| ID | Scenario | Steps | Expected | Result | Notes |
|---|---|---|---|---|---|
| P8-A01 | Dashboard after admin login | Login as `admin@example.com` | **Dashboard** with KPI cards (sales, orders, AOV, conversion) — not title-only placeholder | ⬜ | |
| P8-A02 | Sales trend chart | On Dashboard | Line chart “Sales trend (recent days)” with data | ⬜ | |
| P8-A03 | Catalog / stock KPIs | On Dashboard | Catalog products + out-of-stock metrics visible | ⬜ | |
| P8-A04 | Pull to refresh | Pull down on Dashboard | Reloads KPIs | ⬜ | |
| P8-A05 | Support role dashboard | Login as `support@example.com` | Can view Dashboard (any-admin) | ⬜ | |
| P8-A06 | Simulated KPI failure | Dev Panel → force `admin_dashboard.kpis` → refresh Dashboard | Error + Retry | ⬜ | |
| P8-A07 | Retry after KPI failure | Clear failure → Retry | KPIs load again | ⬜ | |

---

## D. Smoke / regression

| ID | Scenario | Steps | Expected | Result | Notes |
|---|---|---|---|---|---|
| P8-R01 | Storefront shell still works | After Home loads, tap Categories / Search / Profile tabs | Tabs switch; no crash; auth intact | ⬜ | |
| P8-R02 | Admin shell still works | After Dashboard, open Catalog / Orders side-nav items | Placeholders load; no forced logout | ⬜ | |
| P8-R03 | Auth still works | Logout / login again on both apps | Still lands on Home / Dashboard | ⬜ | |

---

## Sign-off

| Check | Status |
|---|---|
| All storefront cases Pass or justified N/A | ⬜ |
| All admin cases Pass or justified N/A | ⬜ |
| CI green on PR | ⬜ |
| Ready to merge `phase/8-dashboard-home` → `develop` | ⬜ |

**Tester sign-off:** ______________________  **Date:** __________

---

## Comment log (optional)

```
P8-S01 Pass
P8-S09 Fail — …
```
