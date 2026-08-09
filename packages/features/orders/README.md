# orders

Post-purchase order tracking and lifecycle management for the customer.

## Phase status

- **15.1 domain/data** — 🟩 **pulled forward for Phase 14.4** (PlaceOrder).
- **15.2–15.4** UI (history, detail, cancel/return) — pending Phase 15.

## Public API (15.1)

- Entities: `Order`, `OrderLineItem`, `OrderStatus`
- `OrderRepository` → mock via `MockSeedStore` (`createOrder` / `getOrder` / `getOrders`)
- Use cases: `CreateOrder`, `GetOrder`, `GetOrders`
- DI: `configureOrdersInjection()`

## Mock call types

- `orders.create` · `orders.get` · `orders.list`

See `docs/04_FEATURE_IMPLEMENTATION_ORDER.md` §9 and
`docs/03_DEVELOPMENT_PHASES.md` Phase 15 (sequencing note with Phase 14).
