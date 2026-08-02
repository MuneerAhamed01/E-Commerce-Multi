# Phase 11 — Search Manual Test Cases

**Branch:** `phase/11-search`  
**PR:** [https://github.com/MuneerAhamed01/E-Commerce-Multi/pull/9](https://github.com/MuneerAhamed01/E-Commerce-Multi/pull/9)  

**Base:** `phase/10-categories` (stacked — merge to `develop` only after Phase 10 merges **and** every case below is `Pass` / justified `N/A`).

| Field | Value |
|---|---|
| Tester | |
| Date | |
| Platform(s) | e.g. macOS storefront / iOS simulator / Chrome |
| Build / commit | `78373bc` (or later on this branch) |
| Overall result | ⬜ Not started · 🟨 In progress · 🟩 Ready to merge |

**How to mark results**

For each case, change the result cell:

- `⬜` → pending  
- `✅ Pass`  
- `❌ Fail` — add a short note in **Notes** (what you saw)  
- `➖ N/A` — only if the step cannot apply on your platform; say why  

When you finish a batch, paste comments here or in chat (e.g. `P11-S05 Fail — …`). I will fix failures, then you re-run only the failed IDs.

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
- Catalog is **100% mock** (`MockSeedStore` 192 products). Search matches name/description. No Firebase.

### Demo path (guest OK if `allowGuestBrowsing`)

1. Optional: login as customer above.  
2. Bottom nav **Search** → `/search` (trending + empty recent by default).  
3. Type a term (e.g. `classic`) — suggestions appear after ~350ms debounce.  
4. Submit or tap a suggestion → `/search/results?q=…`.  
5. Open Filter / Sort sheets; clear filters from zero-results empty state.  
6. Tap a result card → `/products/:productId`.

### Mock call types (Dev Panel)

- `search.products` · `search.suggestions` · `search.facets`

### Filter semantics

All active filter fields are **AND**ed (category + price bucket + min rating + in-stock). Debounce is presentation-only (`AppSearchBar` ≥300ms).

---

## A. Search entry & suggestions

| ID | Scenario | Steps | Expected | Result | Notes |
|---|---|---|---|---|---|
| P11-S01 | Open entry | Bottom nav **Search** | `/search` loads with search bar + **Trending** chips (recent empty by default) | ⬜ | |
| P11-S02 | Empty idle copy | Fresh install / cleared recent | Empty helper (“Find something you love”) + trending visible | ⬜ | |
| P11-S03 | Debounced suggestions | Type `classic` and pause ≥350ms | Suggestion tiles appear (not on every keystroke) | ⬜ | |
| P11-S04 | Clear query | Type then clear the bar | Suggestions hide; trending/recent idle UI returns | ⬜ | |
| P11-S05 | Submit navigates | Type `classic` → keyboard Search / submit | Navigates to `/search/results?q=classic` | ⬜ | |
| P11-S06 | Suggestion tap | Tap a suggestion tile | Navigates to results for that term; term saved to recent | ⬜ | |
| P11-S07 | Trending tap | Tap a **Trending** chip | Navigates to results for that term | ⬜ | |
| P11-S08 | Recent persists | Submit a search → leave Search tab → return | Recent chip shows the term | ⬜ | |
| P11-S09 | Clear recent | With recent chips → **Clear** | Recent list empties; trending remains | ⬜ | |
| P11-S10 | Suggestions failure | Dev Panel → force `search.suggestions` → type a query | Inline error on suggestions; entry still usable | ⬜ | |

---

## B. Results, filters, sort

| ID | Scenario | Steps | Expected | Result | Notes |
|---|---|---|---|---|---|
| P11-S11 | Results load | Open `/search/results?q=classic` | Product grid loads; count label may show | ⬜ | |
| P11-S12 | Typo / no match | Search `zzz-no-such-product-xyz` | Distinct **No results** empty (not error/loading) | ⬜ | |
| P11-S13 | Open filters | Results → Filter icon | Filter sheet with Category / Price / Rating / Availability | ⬜ | |
| P11-S14 | Apply filter AND | Apply In stock + a high min rating (and/or tight price) until empty | Results update; if empty, **Clear filters** CTA shown | ⬜ | |
| P11-S15 | Clear filters CTA | From zero-results with filters → **Clear filters** | Filters cleared; results reload (may become non-empty) | ⬜ | |
| P11-S16 | Active filter chips | Apply a category or price filter | `AppActiveFilterChipRow` shows chips; remove one updates results | ⬜ | |
| P11-S17 | Sort | Sort → Price: Low to High | Order changes to ascending price | ⬜ | |
| P11-S18 | Product tap | Tap a result card | Navigates to `/products/:productId` | ⬜ | |
| P11-S19 | Pagination | Search empty query (all products) → scroll near bottom | More products load (page size ~20) | ⬜ | |
| P11-S20 | Results failure + retry | Force `search.products` → open/retry results | Error + Retry; clear failure → Retry succeeds | ⬜ | |

---

## C. Smoke / regression

| ID | Scenario | Steps | Expected | Result | Notes |
|---|---|---|---|---|---|
| P11-R01 | Categories still works | Open Categories browse/detail | Grid/detail still load | ⬜ | |
| P11-R02 | Products still works | Open `/products` and a product detail | Listing/detail still load | ⬜ | |
| P11-R03 | Home still works | After searching, Home tab | Banners / featured still load | ⬜ | |
| P11-R04 | Auth still works | Logout / login | Lands on Home; session intact | ⬜ | |
| P11-R05 | Shell tabs | Wishlist / Profile tabs | No crash (placeholders OK) | ⬜ | |

---

## Sign-off

| Role | Name | Date | Signature / ack |
|---|---|---|---|
| Implementer | | | |
| QA / human gate | | | |

**Merge rule:** Do **not** merge this PR into `develop` until Phase 10 is on `develop` and Overall result is 🟩 with all applicable cases Pass/N/A.
