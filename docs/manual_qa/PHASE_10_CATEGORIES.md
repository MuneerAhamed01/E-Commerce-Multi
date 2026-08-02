# Phase 10 — Categories Manual Test Cases

**Branch:** `phase/10-categories`  
**PR:** _(filled after open)_  

**Base:** `phase/9-products` (stacked — merge to `develop` only after Phase 9 merges **and** every case below is `Pass` / justified `N/A`).

| Field | Value |
|---|---|
| Tester | |
| Date | |
| Platform(s) | e.g. macOS storefront / iOS simulator / Chrome |
| Build / commit | `8c53d1e` (or later on this branch) |
| Overall result | ⬜ Not started · 🟨 In progress · 🟩 Ready to merge |

**How to mark results**

For each case, change the result cell:

- `⬜` → pending  
- `✅ Pass`  
- `❌ Fail` — add a short note in **Notes** (what you saw)  
- `➖ N/A` — only if the step cannot apply on your platform; say why  

When you finish a batch, paste comments here or in chat (e.g. `P10-S05 Fail — …`). I will fix failures, then you re-run only the failed IDs.

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
- Catalog is **100% mock** (`MockSeedStore` categories ≥15 nodes / 3-level tree + 192 products). No Firebase.

### Demo path (guest OK if `allowGuestBrowsing`)

1. Optional: login as customer above.  
2. Bottom nav **Categories** → `/categories` (top-level grid).  
3. Tap a tile → `/categories/:categoryId` (breadcrumb + chips + filtered products).  
4. Subcategory chip or breadcrumb → ancestor/child category.  
5. Product card → `/products/:productId`.  
6. Home featured category → deep link `/categories/:categoryId`.

### Mock call types (Dev Panel)

- `categories.tree` · `categories.detail`  
- (products listing still uses `products.list` on Category Detail)

---

## A. Category browse

| ID | Scenario | Steps | Expected | Result | Notes |
|---|---|---|---|---|---|
| P10-S01 | Open browse | Bottom nav **Categories** | Top-level category grid loads (skeleton may flash); names like Apparel / Electronics visible | ⬜ | |
| P10-S02 | Open detail from tile | Tap **Apparel** | Navigates to `/categories/cat_apparel` with title Apparel | ⬜ | |
| P10-S03 | In-place drill-down | On browse, tap the drill icon on **Electronics** | Grid shows Phones / Audio; breadcrumb shows Electronics; **Shop Electronics** available | ⬜ | |
| P10-S04 | Browse breadcrumb All | After P10-S03 → tap **All** | Returns to top-level roots | ⬜ | |
| P10-S05 | Browse failure + retry | Dev Panel → force `categories.tree` → open/refresh Categories tab | Error + Retry; clear failure → Retry succeeds | ⬜ | |

---

## B. Category detail & deep link

| ID | Scenario | Steps | Expected | Result | Notes |
|---|---|---|---|---|---|
| P10-S06 | Deep link root category | Open `/categories/cat_apparel` cold (or paste URL) | Detail loads without visiting Browse first; products filtered to Apparel | ⬜ | |
| P10-S07 | Deep link nested category | Open `/categories/cat_electronics_phones` | Detail for Phones; breadcrumb Electronics › Phones; chips for children if any | ⬜ | |
| P10-S08 | Subcategory chip | On Electronics detail → tap **Phones** chip | Goes to Phones detail | ⬜ | |
| P10-S09 | Breadcrumb ancestor | On Phone Cases detail → tap **Electronics** in breadcrumb | Goes to Electronics detail | ⬜ | |
| P10-S10 | Breadcrumb All | On any detail → tap **All** | Goes to `/categories` browse | ⬜ | |
| P10-S11 | Empty leaf products | Open `/categories/cat_electronics_phones_cases` | Category chrome loads; empty products state (“No products found”) — not a crash | ⬜ | |
| P10-S12 | Invalid category | Open `/categories/cat_does_not_exist` | Not-found empty state with **Browse categories** | ⬜ | |
| P10-S13 | Detail failure + retry | Force `categories.detail` → open a valid category | Error + Retry recovers after clearing failure | ⬜ | |
| P10-S14 | Product → detail | On Apparel detail → tap a product card | Navigates to `/products/:id` | ⬜ | |

---

## C. Home integration

| ID | Scenario | Steps | Expected | Result | Notes |
|---|---|---|---|---|---|
| P10-S15 | Featured category tap | Home → tap a featured category | Goes to `/categories/:categoryId` (not bare `/categories`) | ⬜ | |
| P10-S16 | Category banner tap | Home → tap a banner targeting a category (if shown) | Goes to that category’s detail path | ⬜ | |

---

## D. Smoke / regression

| ID | Scenario | Steps | Expected | Result | Notes |
|---|---|---|---|---|---|
| P10-R01 | Products still works | Open `/products` and a product detail | Listing/detail still load | ⬜ | |
| P10-R02 | Home still works | After category browsing, Home tab | Banners / featured still load | ⬜ | |
| P10-R03 | Auth still works | Logout / login | Lands on Home; session intact | ⬜ | |
| P10-R04 | Shell tabs | Search / Profile tabs | No crash; placeholders OK | ⬜ | |

---

## Sign-off

| Role | Name | Date | Signature / ack |
|---|---|---|---|
| Implementer | | | |
| QA / human gate | | | |

**Merge rule:** Do **not** merge this PR into `develop` until Phase 9 is on `develop` and Overall result is 🟩 with all applicable cases Pass/N/A.
