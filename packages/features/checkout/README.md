# checkout

Convert a valid, non-empty cart into a placed order.

## Phase 14

Wizard: address → shipping/payment → review → confirmation.

### Deviations

| Topic | Approach |
|---|---|
| Address book | Mock saved addresses **inside checkout** until Profile Phase 18 |
| Payment methods | Minimal `CheckoutPaymentMethod` **inside checkout** until Payments Phase 16 |
| Orders | Domain/data **15.1 pulled forward** for `PlaceOrder` (UI history waits for Phase 15) |

### Routes

- `/checkout/address`
- `/checkout/shipping-payment`
- `/checkout/review`
- `/checkout/confirmation/:orderId`

### Demo flow

1. Sign in as `noah.patel02@example.com` / `Password123!`
2. Add products to cart → **Checkout**
3. Select Home address → Continue
4. Pick Express + payment → Continue
5. **Place order** → confirmation; cart clears

### Shipping

- Standard $5.99 · Express $12.99 · Overnight $24.99
- Postal code `00000` → shipping unavailable

### Promo

Cart promos (`SAVE10`, etc.) still apply; checkout summary includes discount + shipping.

Manual QA: `docs/manual_qa/PHASE_14_CHECKOUT.md`.
