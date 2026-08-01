# 12 — Manual Test Plan

**Status:** Planning document. Complete manual QA checklist executed in Phase 28 (`03_DEVELOPMENT_PHASES.md`) and re-run before every client release. Automated test coverage (unit/`bloc_test`) is mandated separately per `06_DEVELOPMENT_RULES.md` Rules 32–34; this document governs **manual, exploratory, and end-to-end human verification**.

**How to use this document:** Each checklist item is executed against both the Storefront app (Mobile + Web) and, where applicable, the Admin app. Record Pass/Fail/N-A with tester name, date, build number, and defect ID (if failed) in the QA log referenced from `03_DEVELOPMENT_PHASES.md` Milestone 28.1. A release does not proceed past `13_CLIENT_DELIVERY_CHECKLIST.md` with any open Critical/High item from this plan.

**Test data prerequisite:** Execute against the seeded `default_tenant` mock data set, using the documented demo accounts (one customer, one of each `AdminRole`) established in Phase 6/7's mock fixtures.

---

## 1. Authentication

- [ ] Register a new account with valid data → session created, redirected to Home.
- [ ] Register with an already-used email → clear inline error, no account created.
- [ ] Register with a weak password → strength indicator reflects it, submission blocked until policy met.
- [ ] Login with valid credentials → redirected to Home (or role-appropriate Admin landing).
- [ ] Login with invalid credentials → inline error, no navigation.
- [ ] Login as a suspended customer (per Admin Customer Management) → specific "account suspended" message, not a generic error.
- [ ] Forgot Password with a registered email/phone → proceeds to OTP step.
- [ ] Forgot Password with an unregistered email/phone → neutral message (no account-enumeration leak).
- [ ] OTP Verification with correct code → proceeds; with incorrect code → inline error; with expired code → "resend" flow works.
- [ ] Logout → session cleared; attempting to navigate back to a protected route redirects to Login.
- [ ] Kill and relaunch the app with a previously valid session → skips Login, lands on Home directly.
- [ ] Deep link to a protected route while logged out → redirected to Login, then to the originally requested route after successful login.
- [ ] Admin Login with each seeded `AdminRole` → each lands on Admin Dashboard with role-appropriate nav visible.

## 2. Products

- [ ] Product Listing loads and paginates without duplicate or skipped items when scrolling to the end.
- [ ] Product Listing shows a loading skeleton on first load and an inline loader while paginating.
- [ ] Product Listing simulated fetch failure (dev-panel failure injection) shows Error state with working Retry.
- [ ] Product Detail displays correct images, price, description, and variant options for a multi-variant product.
- [ ] Selecting an out-of-stock variant disables/blocks Add to Cart with a clear message; other variants remain selectable.
- [ ] Product Detail "Related Products" row navigates correctly and updates the screen when tapped (params refresh, not a stale screen).
- [ ] Submitting a review while unauthenticated redirects to Login and returns to the same Product Detail (with review form pre-focused) after login.
- [ ] Submitting a valid review appears in the Review List without requiring an app restart.
- [ ] Product with zero reviews shows an appropriate empty state in the review section, not a blank area.

## 3. Categories

- [ ] Category Browse renders the full seeded tree to at least 3 levels deep.
- [ ] Category Detail correctly filters Product Listing to only that category's products.
- [ ] Breadcrumb navigation jumps correctly to any ancestor category.
- [ ] Deep link directly to a nested category resolves without requiring prior navigation through Browse.
- [ ] Category with zero assigned products still opens to a correct empty Product Listing (not hidden from Browse).

## 4. Search

- [ ] Typing a query shows debounced live suggestions (verify no excessive rapid re-querying while typing quickly).
- [ ] Submitting a query navigates to Search Results with matching items.
- [ ] Query with zero matches shows a distinct empty state (not the same as loading or error), with a "clear filters"/"browse instead" CTA.
- [ ] Applying a price-range filter, a category filter, and a rating filter together narrows results correctly (AND semantics).
- [ ] Sort options (price asc/desc, newest, rating) visibly reorder results correctly.
- [ ] Recent Searches populates after a search and is tappable to re-run; "clear recent searches" empties it.
- [ ] Search entry with no recent searches shows trending/suggested terms instead of a blank screen.

## 5. Wishlist

- [ ] Adding a product to Wishlist from Product Listing/Detail reflects instantly on the Wishlist screen.
- [ ] Removing an item from the Wishlist screen instantly updates the toggle state shown on that product's card/detail elsewhere in the app.
- [ ] Wishlist toggle while logged out redirects to Login and returns with the action completed post-login.
- [ ] Empty Wishlist shows an empty state with a "Browse Products" CTA.
- [ ] A wishlisted item that later goes out of stock shows an out-of-stock indicator but is not silently removed.

## 6. Cart

- [ ] Adding an item to Cart shows a confirmation (snackbar) and updates the shell Cart badge count immediately.
- [ ] Increasing/decreasing quantity in Cart respects available stock (cannot exceed it; stepper disables at max).
- [ ] Removing the last item in Cart shows the Cart empty state with a "Start Shopping" CTA.
- [ ] Applying a valid promo code updates the total and shows the discount line item.
- [ ] Applying an invalid/expired/exhausted promo code shows a specific inline error, cart total unaffected.
- [ ] Removing an applied promo code reverts the total correctly.
- [ ] Cart contents persist after fully closing and reopening the app.
- [ ] Revisiting Cart after an item's stock changed (simulate via Admin Inventory adjustment in another session) shows an auto-adjust notice.

## 7. Checkout

- [ ] Cannot proceed from the Address step without a valid selected/entered address.
- [ ] Adding a new address mid-checkout returns correctly to the checkout flow with the new address selected (wizard state preserved).
- [ ] Cannot proceed from Shipping & Payment step without a shipping method and a payment method (or COD if enabled) selected.
- [ ] Navigating back a step preserves previously entered data (no re-entry required).
- [ ] Order Review accurately reflects items, address, shipping cost, discount, and total matching the Cart at time of entry.
- [ ] Placing an order succeeds, creates a new Order visible immediately in Order History, and navigates to Order Confirmation.
- [ ] Double-tapping "Place Order" does not create two separate orders (button disables immediately on first tap).
- [ ] Order Confirmation screen is not reachable via direct back-navigation after completion (verify back button behavior post-order).
- [ ] Direct deep link to a confirmation URL without a valid just-placed order redirects to Order History gracefully.
- [ ] If item price/stock changed between adding to Cart and placing the order (simulate via Admin), the user is warned before the order is placed.

## 8. Orders

- [ ] Order History lists all of the demo customer's orders with correct statuses.
- [ ] Order Detail shows correct line items, address, and a chronologically correct tracking timeline.
- [ ] Cancel action is available only for statuses where policy allows (e.g., Placed/Processing) and hidden/disabled otherwise.
- [ ] Cancelling an order updates its status immediately in both Order Detail and Order History.
- [ ] Requesting a return follows the same pattern with correct status transition.
- [ ] Empty Order History (a fresh account) shows an appropriate empty state.
- [ ] "Buy Again" from an order line item navigates to the correct current Product Detail.

## 9. Payments

- [ ] Adding a new mock payment method with valid data succeeds and appears in the list, masked.
- [ ] Adding a payment method with invalid card number/expiry/CVV is blocked with inline validation (Luhn check, expiry check).
- [ ] Removing a non-default payment method succeeds directly.
- [ ] Removing the default (or only) payment method requires setting a new default first, or is blocked with a clear explanation.
- [ ] Selecting a payment method during Checkout correctly carries through to Order Review and the placed order's record.
- [ ] Card details are never visible in full (always masked) anywhere in the UI, including after adding.

## 10. Notifications

- [ ] Notification Center lists seeded notifications with correct read/unread visual state.
- [ ] Unread badge count on the shell bell icon matches the actual unread count and updates on mark-as-read.
- [ ] Tapping an order-related notification deep-links to the correct Order Detail.
- [ ] Tapping a notification referencing a deleted/unavailable entity fails gracefully (no crash, clear fallback).
- [ ] Disabling a notification category in Preferences stops new notifications of that category from being generated (verify via Developer Panel's "Simulate Notification").
- [ ] Empty Notification Center (new account) shows an appropriate empty state.

## 11. Admin — Access Control

- [ ] Each seeded `AdminRole` sees only its permitted side-nav sections.
- [ ] Direct URL entry (Web) to a route outside a role's permission redirects to Access Denied, not a broken/blank page.
- [ ] SuperAdmin can access every admin section, including Tenant Management.
- [ ] Logging out of the Admin app clears session and blocks back-navigation into protected admin routes.

## 12. Admin — Catalog & Inventory

- [ ] Creating a new product with all required fields succeeds and the product appears immediately in the storefront's Product Listing (same session).
- [ ] Creating a product with missing required fields is blocked with inline validation.
- [ ] Editing an existing product's price/stock/images reflects immediately in the storefront Product Detail.
- [ ] Deleting a category with assigned products or child categories is blocked with a clear explanation.
- [ ] Reordering categories via drag-and-drop (or equivalent) persists the new order, reflected in storefront Category Browse.
- [ ] Adjusting stock via Stock Adjustment updates Inventory Overview and, if crossing the threshold, populates Low Stock Alerts without a manual refresh.
- [ ] Stock adjustment history/audit trail correctly records reason, delta, and actor.
- [ ] Bulk status update (e.g., deactivate multiple products) via `BulkActionToolbar` applies to all selected rows correctly.

## 13. Admin — Orders & Customers

- [ ] Order Management List filters by status/date correctly.
- [ ] Updating an order's status only allows legal transitions (illegal transitions absent from the control, not just rejected).
- [ ] A status update is reflected in the customer's Order History/Detail within the same session.
- [ ] Issuing a mock refund updates the order record and is visible in Order Detail.
- [ ] Customer List search correctly filters by name/email/phone.
- [ ] Suspending a customer immediately blocks that mock account's ability to log in to the storefront (same session).
- [ ] Customer Detail correctly links to and from that customer's Order Detail records.

## 14. Admin — Marketing & Tenant Management

- [ ] Creating a coupon in Admin Marketing makes it immediately usable in the storefront Cart's promo code field (same session).
- [ ] Deactivating/expiring a coupon is reflected as unusable in the storefront immediately.
- [ ] Creating/editing a banner appears correctly (image, target route, order) on the storefront Home immediately.
- [ ] Editing Tenant Branding (colors/logo) updates the Branding Editor's Live Preview instantly.
- [ ] Switching the active demo tenant (Tenant Switcher, dev-only) restyles both apps consistently with zero code changes, per the Phase 26 rebrand verification milestone.
- [ ] Disabling a feature flag hides its nav entry and blocks its route (falls through to 404, not Access Denied) in both apps.
- [ ] Re-enabling a feature flag restores the nav entry and route immediately.

## 15. Profile, Settings & Support

- [ ] Editing profile fields (name/email/phone) saves and persists correctly, with shared validators enforced.
- [ ] Address Book add/edit/delete/set-default all function correctly and stay in sync with Checkout's address list.
- [ ] Deleting an address referenced by an active order is blocked or requires explicit confirmation.
- [ ] Changing theme (light/dark) applies instantly across every currently visible screen.
- [ ] Changing language updates all visible `intl`-sourced strings without requiring a restart (or documents the restart requirement if that's the chosen implementation — verify against the actual behavior built).
- [ ] Change Password requires correct current password and enforces the password policy.
- [ ] FAQ search and category filter both function correctly; zero-result search shows a "Contact Us" CTA.
- [ ] Creating a support ticket with valid data succeeds and is visible in Ticket Status with a trackable ID.

## 16. Responsive Behaviour

- [ ] Every screen in `07_SCREEN_CATALOG.md` is manually verified at three representative widths: ~375px (mobile), ~768px (tablet), ~1440px (desktop/web).
- [ ] No screen shows horizontal overflow/clipping at any of the three widths.
- [ ] `AdminDataTable`-based screens correctly fall back to a card layout below the tablet breakpoint (per RESP-TABLE pattern).
- [ ] Storefront bottom navigation is replaced/adapted appropriately on wide Web viewports (per tenant's chosen desktop navigation pattern, if different from mobile).
- [ ] Admin side navigation collapses to a drawer below the desktop breakpoint.

## 17. Accessibility

- [ ] All interactive elements have a minimum 44x44 logical-pixel tap target.
- [ ] Text contrast against backgrounds meets WCAG AA (4.5:1 for body text) for both light and dark themes, including tenant-customized brand colors within reasonable bounds (flagged if a tenant's chosen palette fails — see Branding Editor's contrast warning, `07_SCREEN_CATALOG.md` §T).
- [ ] All images/icons conveying meaning have semantic labels (`Semantics`/`tooltip`) verified via screen reader spot-check (VoiceOver/TalkBack/Web screen reader) on at least: Login, Product Detail, Cart, Checkout, Admin Dashboard.
- [ ] All forms support keyboard-only navigation (Web) including logical tab order.
- [ ] Focus indicators are visible on Web for keyboard navigation.

## 18. Dark Mode

- [ ] Every screen renders correctly in dark mode with no illegible text-on-background combinations.
- [ ] Images/illustrations with light backgrounds (if any) have appropriate dark-mode variants or transparent backgrounds.
- [ ] Charts (Admin Analytics/Dashboard) remain legible in dark mode (series colors distinguishable).
- [ ] Switching theme mode does not require an app restart and does not lose current navigation position or in-progress form data.

## 19. Offline Behaviour

- [ ] Toggling device airplane mode surfaces the `NetworkOfflineBanner` within a reasonable delay.
- [ ] Attempting a write action (Add to Cart, Place Order, Submit Review) while offline fails fast with a clear, specific error rather than hanging indefinitely.
- [ ] Previously loaded screens (already-fetched mock data held in memory) remain viewable while offline; navigating to not-yet-loaded data shows the Error state, not a crash.
- [ ] Reconnecting clears the offline banner and allows retried actions to succeed.

## 20. Performance

- [ ] Cold start time to first interactive screen is measured and recorded per platform (Mobile/Web) as a baseline for future regression comparison.
- [ ] Product Listing/Search Results scroll smoothly (no visible jank) through at least 200 mock items via pagination.
- [ ] Admin tables with 100+ mock rows scroll and sort without noticeable lag.
- [ ] Images are cached after first load (verify no re-fetch flicker on repeat navigation to the same Product Detail).
- [ ] App memory usage is monitored during an extended session (30+ min, heavy navigation) for obvious leaks (steadily climbing memory with no plateau).

## 21. Navigation

- [ ] Every route in `09_ROUTING_PLAN.md` §2 and §3 is manually visited at least once and confirmed to render the correct screen.
- [ ] Browser back/forward buttons (Web) behave correctly across shell branch navigation and pushed screens.
- [ ] Deep linking to at least one route per major feature resolves correctly without prior in-app navigation.
- [ ] 404 screen appears for an intentionally invalid path and its CTA returns to a sensible landing screen.
- [ ] Maintenance mode flag (toggled via config for test purposes) correctly blocks all routes except the maintenance screen, independently for storefront vs. admin.
- [ ] Already-authenticated users are redirected away from Login/Register if navigated to directly.

## 22. Error Handling

- [ ] Every async screen's simulated failure (via Developer Panel failure injection) shows the correct `AppErrorState` with a working Retry that successfully recovers once the simulated failure is cleared.
- [ ] Form validation errors are field-specific and clear, never a generic "something went wrong."
- [ ] A genuinely unexpected error (forced via a debug hook, if available) is caught by the global error zone and does not crash the app to a blank/red screen in a release-mode build.
- [ ] Error messages are sourced through `FailureMessageMapper`/`TenantConfig.copyOverrides` (spot-check that switching tenant, per the Tenant Switcher, changes at least one error message's wording if that tenant has an override configured).

## 23. Developer Panel

- [ ] Developer Panel and Tenant Switcher are reachable in `dev`/`staging` builds and completely absent (no menu entry, route returns 404) in a `prod`-flavor build.
- [ ] "Reset Mock Data" returns all features to their seeded baseline state without requiring an app reinstall.
- [ ] Environment switcher correctly reflects and (where permitted) changes the active environment indicator.
- [ ] "Simulate Notification" successfully creates a new item visible in Notification Center of the expected category.
- [ ] Mock latency/failure-injection controls visibly affect the behavior of at least one live screen (e.g., Product Listing) when toggled.

---

## Sign-off

| Area | Tester | Build | Result | Defects Logged | Date |
|---|---|---|---|---|---|
| Authentication | | | | | |
| Commerce (Products→Payments) | | | | | |
| Notifications/Profile/Settings/Support | | | | | |
| Admin (all sections) | | | | | |
| Cross-cutting (Responsive/A11y/Dark Mode/Offline/Perf/Nav/Error/Dev Panel) | | | | | |

**QA Lead sign-off required before proceeding to `13_CLIENT_DELIVERY_CHECKLIST.md`.**
