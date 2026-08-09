# Phase 14 — Checkout Manual Test Cases

**Branch:** `phase/14-checkout`  
**PR:** _(filled after open)_  

**Base:** `phase/13-cart` (stacked — merge to `develop` only after Phase 13 merges **and** every case below is `Pass` / justified `N/A`).

| Field | Value |
|---|---|
| Tester | |
| Date | |
| Platform(s) | e.g. macOS storefront / iOS simulator / Chrome |
| Build / commit | _(fill after push)_ |
| Overall result | ⬜ Not started · 🟨 In progress · 🟩 Ready to merge |

**How to mark results**

For each case, change the result cell:

- `⬜` → pending  
- `✅ Pass`  
- `❌ Fail` — add a short note in **Notes** (what you saw)  
- `➖ N/A` — only if the step cannot apply on your platform; say why  

When you finish a batch, paste comments here or in chat (e.g. `P14-S05 Fail — …`). I will fix failures, then you re-run only the failed IDs.

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
- Catalog / cart / checkout are **100% mock**.

### Demo path

1. Sign in as Noah → add product(s) to cart → **Checkout**.  
2. Address step → select **Home** (or add address) → **Continue**.  
3. Shipping & payment → pick Express + Visa/COD → costs update → **Continue**.  
4. Review → **Place order** → confirmation with order number; cart empty.  
5. Back from confirmation should **not** return to review / re-submit.

### Shipping (mock)

| Method | Cost (USD) | ETA |
|---|---|---|
| Standard | $5.99 | 5–7 days |
| Express | $12.99 | 2–3 days |
| Overnight | $24.99 | next day |

- Postal code `00000` → shipping unavailable (add an address with this postal for QA).

### Promos

Cart promos (`SAVE10`, `SAVE5`, …) still apply; review total = cart total + shipping.

### Deviations (documented)

| Topic | Approach |
|---|---|
| Address book | Mock inside checkout until Profile Phase 18 |
| Payment methods | Minimal local list until Payments Phase 16 |
| Orders | Domain/data **15.1 pulled forward**; history UI waits for Phase 15.2+ |

### Mock call types (Dev Panel)

- `checkout.getAddresses` · `checkout.saveAddress` · `checkout.getShippingMethods`
- `checkout.calculateShipping` · `checkout.getPaymentMethods`
- `orders.create` · `orders.get` · `orders.list`

---

## A. Auth & entry

| ID | Scenario | Steps | Expected | Result | Notes |
|---|---|---|---|---|---|
| P14-S01 | Guest blocked | Guest, non-empty cart → Checkout | Login with `redirect=/checkout/address` | ⬜ | |
| P14-S02 | Return-to after login | Complete login from S01 | Lands on address step | ⬜ | |
| P14-S03 | Empty cart blocked | Authenticated, empty cart → open `/checkout/address` | Unavailable / empty-cart messaging | ⬜ | |
| P14-S04 | Cart CTA navigates | Auth + items → Checkout | `/checkout/address` | ⬜ | |

---

## B. Address step

| ID | Scenario | Steps | Expected | Result | Notes |
|---|---|---|---|---|---|
| P14-S05 | Seeded addresses | Noah → address step | Home (default) + Work listed | ⬜ | |
| P14-S06 | Must select | Deselect / no selection | Continue disabled | ⬜ | |
| P14-S07 | Select & continue | Select Home → Continue | `/checkout/shipping-payment` | ⬜ | |
| P14-S08 | Add address | Fill form → Save | New card appears; selectable | ⬜ | |
| P14-S09 | Validation | Save with empty line1 | Field error; cannot save | ⬜ | |
| P14-S10 | Back preserves | Shipping → Back | Prior address still selected | ⬜ | |

---

## C. Shipping & payment

| ID | Scenario | Steps | Expected | Result | Notes |
|---|---|---|---|---|---|
| P14-S11 | Three methods | Open shipping step | Standard / Express / Overnight | ⬜ | |
| P14-S12 | Cost updates | Select Express | Summary shipping $12.99 | ⬜ | |
| P14-S13 | Payment required | Shipping only, no payment | Continue disabled | ⬜ | |
| P14-S14 | Both selected | Shipping + payment → Continue | `/checkout/review` | ⬜ | |
| P14-S15 | Unavailable postal | Address with postal `00000` → pick shipping | Unavailable message; cannot continue | ⬜ | |

---

## D. Review & place

| ID | Scenario | Steps | Expected | Result | Notes |
|---|---|---|---|---|---|
| P14-S16 | Summary matches | Review with promo + Express | Line items, discount, shipping, total | ⬜ | |
| P14-S17 | Place order | Tap Place order | Confirmation; order id shown | ⬜ | |
| P14-S18 | Cart cleared | After place → Cart tab | Empty cart | ⬜ | |
| P14-S19 | Double-tap | Mash Place order | Only one order created | ⬜ | |
| P14-S20 | Stack replace | Confirmation → system back | Does not re-open review / re-submit | ⬜ | |

---

## E. Confirmation

| ID | Scenario | Steps | Expected | Result | Notes |
|---|---|---|---|---|---|
| P14-S21 | Receipt | After place | Order number + totals visible | ⬜ | |
| P14-S22 | Continue shopping | Tap CTA | Home | ⬜ | |
| P14-S23 | Bad deep link | Open `/checkout/confirmation/not-a-real-id` | Error / not-found; not a crash | ⬜ | |

---

## F. Smoke / regression

| ID | Scenario | Steps | Expected | Result | Notes |
|---|---|---|---|---|---|
| P14-R01 | Cart still works | Add / promo / badge | Phase 13 behaviors intact | ⬜ | |
| P14-R02 | Wishlist still works | Toggle / list | No crash | ⬜ | |
| P14-R03 | Auth still works | Logout / login | Session OK | ⬜ | |
| P14-R04 | Home / catalog | Home + products | Still load | ⬜ | |

---

## Sign-off

| Role | Name | Date | Signature / ack |
|---|---|---|---|
| Implementer | | | |
| QA / human gate | | | |

**Merge rule:** Do **not** merge this PR into `develop` until Phase 13 is on `develop` and Overall result is 🟩 with all applicable cases Pass/N/A.
