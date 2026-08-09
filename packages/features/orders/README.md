# orders

Post-purchase order tracking and lifecycle management for the customer.

## Phase status

- **15.1 domain/data** — 🟩 complete (pulled forward for Phase 14.4 PlaceOrder).
- **15.2 order history** — 🟩 complete.
- **15.3 order detail & tracking** — 🟩 complete.
- **15.4 cancel/return** — 🟩 complete.

## Public API

- Entities: `Order`, `OrderLineItem`, `OrderStatus`, `OrderTrackingEvent`
- `OrderRepository` → mock via `MockSeedStore` (create/get/list/tracking/cancel/return)
- Use cases: `CreateOrder`, `GetOrder`, `GetOrders`, `GetOrderTrackingEvents`,
  `CancelOrder`, `RequestReturn`
- Presentation: `OrderHistoryScreen`, `OrderDetailScreen`, `OrderListBloc`,
  `OrderDetailBloc`, `OrderRoutes`, status badge / list tile / timeline /
  cancel-return dialog
- DI: `configureOrdersInjection()`

## Policy

- **Cancel** — `placed` or `processing` only (re-validated in mock before apply).
- **Request return** — `delivered` only.

## Mock call types

- `orders.create` · `orders.get` · `orders.list`
- `orders.tracking` · `orders.cancel` · `orders.return`

## Demo

Sign in as Noah (`noah.patel02@example.com` / `Password123!`) → Profile →
**My orders**, or place an order and tap **View order** on confirmation.

See `docs/04_FEATURE_IMPLEMENTATION_ORDER.md` §9 and
`docs/03_DEVELOPMENT_PHASES.md` Phase 15.
