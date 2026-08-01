# 07 — Screen Catalog

**Status:** Planning document. Every screen in the platform, fully specified. Cross-referenced with `04_FEATURE_IMPLEMENTATION_ORDER.md` (feature ownership) and `09_ROUTING_PLAN.md` (exact route paths).

---

## Legend (referenced by every screen entry below to avoid repetition)

**Responsive Pattern Codes**

| Code | Mobile (< 600px) | Tablet (600–1024px) | Desktop (> 1024px) |
|---|---|---|---|
| RESP-DETAIL | Single column, full-width, scrollable | Single column, max-width 720px, centered | Two-column: content + sticky side panel, max-width 1200px |
| RESP-GRID | 2-column grid | 3-column grid | 4–6 column grid (fluid) |
| RESP-FORM | Full-screen step, sticky bottom action bar | Centered card, max-width 560px | Centered card, max-width 560px, side illustration optional |
| RESP-LIST | Full-width list tiles | Full-width list tiles, larger touch targets unnecessary | List with master-detail split view where a detail screen exists |
| RESP-DASH | Stacked cards, vertical scroll | 2-column card grid | Multi-column dashboard grid with persistent side nav |
| RESP-TABLE | Card-per-row fallback (no horizontal scroll) | Horizontally scrollable data table | Full data table, all columns, inline row actions |
| RESP-WIZARD | Full-screen per step, linear progress header | Centered card per step, max-width 640px | Centered card per step, max-width 640px |

**Permission Codes**

| Code | Meaning |
|---|---|
| PUBLIC | No authentication required |
| AUTH | Any authenticated customer |
| ADMIN:ANY | Any authenticated admin role |
| ADMIN:SuperAdmin | SuperAdmin role only |
| ADMIN:CatalogManager | CatalogManager or SuperAdmin |
| ADMIN:OrderManager | OrderManager or SuperAdmin |
| ADMIN:MarketingManager | MarketingManager or SuperAdmin |
| ADMIN:SupportAgent | SupportAgent or SuperAdmin |
| DEV | Non-production flavors only, hidden in prod builds |

---

## A. Authentication

### Splash
- **Purpose:** Resolve session state and route to the correct destination on cold start.
- **User Type:** Anyone (pre-auth-check).
- **Nav Entry:** App cold start only.
- **Nav Exit:** Auto-navigates to Onboarding (first run), Login (no session), or Home/Admin Dashboard (valid session) — never user-dismissed.
- **Widgets:** Tenant-branded logo, loading indicator.
- **API Dependencies:** `GetCurrentUser`, `RefreshSession`.
- **Mock Data:** Reads persisted mock session if present.
- **Edge Cases:** Corrupted/expired persisted session falls back to Login, not a crash.
- **Permissions:** PUBLIC.
- **Responsive:** RESP-DETAIL (centered logo at all sizes; no scroll).
- **Admin Behaviour:** Admin app has its own Splash resolving to Admin Dashboard or Admin Login.

### Onboarding
- **Purpose:** First-run introduction to the tenant's value proposition (tenant-configurable slides).
- **User Type:** First-time, unauthenticated user.
- **Nav Entry:** From Splash, only when no "onboarding seen" flag set.
- **Nav Exit:** → Login/Register (skip or complete).
- **Widgets:** `PageView` slide carousel, skip button, page indicator.
- **API Dependencies:** None (static/tenant-config-driven content).
- **Mock Data:** Default onboarding slide set per tenant config.
- **Edge Cases:** Zero slides configured → skip straight to Login.
- **Permissions:** PUBLIC.
- **Responsive:** RESP-DETAIL.
- **Admin Behaviour:** N/A (not shown in Admin app).

### Login
- **Purpose:** Authenticate an existing user.
- **User Type:** Returning unauthenticated user.
- **Nav Entry:** From Splash/Onboarding, from Logout, from any guarded-route redirect (with return-to param).
- **Nav Exit:** → Home (customer) / Admin Dashboard (admin) on success; → Register, → Forgot Password.
- **Widgets:** `AuthTextField` (email/username, password), `AuthPrimaryButton`, error banner.
- **API Dependencies:** `LoginUser`.
- **Mock Data:** Seeded mock user credentials (documented in QA test data appendix, `12_MANUAL_TEST_PLAN.md`).
- **Edge Cases:** Invalid credentials, network-failure simulation, account-suspended (admin customer management) failure message.
- **Permissions:** PUBLIC.
- **Responsive:** RESP-FORM.
- **Admin Behaviour:** Admin app's Login is a distinct route (`/admin/login`) but shares this feature's Bloc/use case; on success routes by role.

### Register
- **Purpose:** Create a new customer account. *(Admin accounts are provisioned by a SuperAdmin via Admin Customer/Staff management, not self-registration.)*
- **User Type:** New unauthenticated user.
- **Nav Entry:** From Login.
- **Nav Exit:** → OTP Verification (if tenant requires email/phone verification) or → Home.
- **Widgets:** `AuthTextField` (name/email/phone/password), `PasswordStrengthIndicator`, terms checkbox.
- **API Dependencies:** `RegisterUser`.
- **Mock Data:** New entries added to in-memory mock user store for the session.
- **Edge Cases:** Duplicate email, weak password, terms not accepted.
- **Permissions:** PUBLIC.
- **Responsive:** RESP-FORM.
- **Admin Behaviour:** N/A.

### Forgot Password
- **Purpose:** Initiate password recovery.
- **User Type:** Unauthenticated user who forgot credentials.
- **Nav Entry:** From Login.
- **Nav Exit:** → OTP Verification.
- **Widgets:** `AuthTextField` (email/phone).
- **API Dependencies:** `RequestPasswordReset`.
- **Mock Data:** Any seeded user email/phone accepted; unregistered input still shows a neutral success message (no user enumeration).
- **Edge Cases:** Unregistered email (neutral message, no enumeration leak).
- **Permissions:** PUBLIC.
- **Responsive:** RESP-FORM.
- **Admin Behaviour:** Shared for admin login recovery.

### OTP Verification
- **Purpose:** Confirm identity via a one-time code (mocked).
- **User Type:** Unauthenticated user mid-registration or password-recovery.
- **Nav Entry:** From Register or Forgot Password.
- **Nav Exit:** → Home (post-registration) or → Reset Password step → Login.
- **Widgets:** `OtpInputRow`, resend-code timer.
- **API Dependencies:** `VerifyOtp`.
- **Mock Data:** Mock OTP is a fixed/logged dev value (e.g., always `123456` in non-prod) for QA convenience.
- **Edge Cases:** Wrong code, expired code, resend rate-limiting simulation.
- **Permissions:** PUBLIC.
- **Responsive:** RESP-FORM.
- **Admin Behaviour:** N/A.

---

## B. Dashboard / Home

### Home
- **Purpose:** Customer landing surface post-login; surfaces banners, categories, featured products.
- **User Type:** Authenticated (or guest, per tenant flag `allowGuestBrowsing`).
- **Nav Entry:** Post-login default; bottom-nav "Home" tab.
- **Nav Exit:** → Product Detail, → Category Detail, → Search, → Cart.
- **Widgets:** `BannerCarousel`, `FeaturedCategoryRow`, `FeaturedProductRow`.
- **API Dependencies:** `GetHomeFeed`.
- **Mock Data:** Seeded banners/featured lists per default tenant.
- **Edge Cases:** No featured content configured → graceful empty sections (not a full-page empty state); banner image load failure → placeholder.
- **Permissions:** PUBLIC or AUTH depending on `allowGuestBrowsing` flag.
- **Responsive:** RESP-DASH.
- **Admin Behaviour:** N/A (Admin has its own Dashboard, see section H).

---

## C. Products

### Product Listing
- **Purpose:** Browse the catalog (optionally filtered by category).
- **User Type:** PUBLIC/AUTH.
- **Nav Entry:** Home, Category Detail, Search Results ("view all"), bottom nav "Shop" tab.
- **Nav Exit:** → Product Detail; → Filter/Sort sheet.
- **Widgets:** `ProductGrid`, `ProductCard`, `ActiveFilterChipRow`, pagination loader.
- **API Dependencies:** `GetProducts`.
- **Mock Data:** ≥50 seeded products.
- **Edge Cases:** Empty category, end-of-pagination, simulated fetch failure mid-scroll (retry affordance).
- **Permissions:** PUBLIC or AUTH per `allowGuestBrowsing`.
- **Responsive:** RESP-GRID.
- **Admin Behaviour:** N/A.

### Product Detail
- **Purpose:** Full product information, variant selection, reviews, add-to-cart/wishlist.
- **User Type:** PUBLIC/AUTH.
- **Nav Entry:** Product Listing, Search Results, Home, Wishlist, Order line item ("buy again").
- **Nav Exit:** → Cart (via add-to-cart, no full navigation), → Related Product Detail, → Login (if action requires auth), → Review submission (inline/modal).
- **Widgets:** `ProductGallery`, `VariantSelector`, `RatingSummary`, `ReviewList`, `ReviewSubmissionForm`, `WishlistToggleButton`, sticky add-to-cart bar.
- **API Dependencies:** `GetProductDetail`, `GetRelatedProducts`, `GetProductReviews`, `SubmitProductReview`.
- **Mock Data:** Multi-variant products with pre-seeded reviews.
- **Edge Cases:** Out-of-stock variant, product removed after being linked to (404-in-place state), zero reviews.
- **Permissions:** PUBLIC (view) / AUTH (review, add-to-cart may allow guest cart per tenant flag).
- **Responsive:** RESP-DETAIL.
- **Admin Behaviour:** N/A (admin edits happen in Admin Catalog, section J).

---

## D. Categories

### Category Browse
- **Purpose:** Visual entry point into the category tree.
- **User Type:** PUBLIC/AUTH.
- **Nav Entry:** Bottom nav "Categories" tab, Home.
- **Nav Exit:** → Category Detail, → subcategory drill-down (in place).
- **Widgets:** `CategoryGridTile`, `SubcategoryChipRow`.
- **API Dependencies:** `GetCategoryTree`.
- **Mock Data:** ≥3-level seeded tree.
- **Edge Cases:** Category with zero products still browsable (shows empty product list, not hidden).
- **Permissions:** PUBLIC or AUTH per flag.
- **Responsive:** RESP-GRID.
- **Admin Behaviour:** N/A.

### Category Detail
- **Purpose:** Filtered product listing scoped to a category (reuses Product Listing UI).
- **User Type:** PUBLIC/AUTH.
- **Nav Entry:** Category Browse, deep link.
- **Nav Exit:** → Product Detail; → parent category via breadcrumb.
- **Widgets:** `CategoryBreadcrumb`, `ProductGrid` (shared).
- **API Dependencies:** `GetCategoryDetail`, `GetProducts` (category-filtered).
- **Mock Data:** Shared with Product Listing.
- **Edge Cases:** Direct deep link to an invalid/deleted category → 404 route.
- **Permissions:** PUBLIC or AUTH per flag.
- **Responsive:** RESP-GRID.
- **Admin Behaviour:** N/A.

---

## E. Search

### Search (Entry)
- **Purpose:** Query input with suggestions and recent/trending searches.
- **User Type:** PUBLIC/AUTH.
- **Nav Entry:** Shell search icon (persistent across shell), Home.
- **Nav Exit:** → Search Results (on submit or suggestion tap).
- **Widgets:** `SearchBar`, `RecentSearchChip`, `SearchSuggestionTile`.
- **API Dependencies:** `GetSearchSuggestions`, `GetRecentSearches`.
- **Mock Data:** Empty recent-search list by default; static trending-terms list.
- **Edge Cases:** No recent searches (empty state with trending suggestions).
- **Permissions:** PUBLIC or AUTH per flag.
- **Responsive:** RESP-DETAIL.
- **Admin Behaviour:** N/A.

### Search Results
- **Purpose:** Display and refine (filter/sort) query results.
- **User Type:** PUBLIC/AUTH.
- **Nav Entry:** Search (entry) on submit.
- **Nav Exit:** → Product Detail; → Filter sheet; → Sort sheet.
- **Widgets:** `ProductGrid` (shared), `FilterBottomSheet`, `SortBottomSheet`, `ActiveFilterChipRow`.
- **API Dependencies:** `SearchProducts`.
- **Mock Data:** Shared Products fixtures.
- **Edge Cases:** Zero results (distinct empty state with "clear filters" affordance), typo/no-match query.
- **Permissions:** PUBLIC or AUTH per flag.
- **Responsive:** RESP-GRID.
- **Admin Behaviour:** N/A.

---

## F. Wishlist

### Wishlist
- **Purpose:** View and manage saved products.
- **User Type:** AUTH.
- **Nav Entry:** Shell nav / Profile menu icon.
- **Nav Exit:** → Product Detail; remove-in-place (no navigation).
- **Widgets:** `WishlistGrid`, `ProductCard` (shared), swipe-to-remove or explicit remove button.
- **API Dependencies:** `GetWishlist`, `RemoveFromWishlist`.
- **Mock Data:** Demo user pre-seeded with sample items.
- **Edge Cases:** Empty wishlist (empty state with "browse products" CTA); wishlisted product later goes out of stock (badge shown, not removed).
- **Permissions:** AUTH.
- **Responsive:** RESP-GRID.
- **Admin Behaviour:** N/A.

---

## G. Cart

### Cart
- **Purpose:** Review and adjust items before checkout; apply promo codes.
- **User Type:** AUTH (or guest cart if tenant flag allows).
- **Nav Entry:** Shell cart icon/badge, add-to-cart confirmation "View Cart" action.
- **Nav Exit:** → Checkout (Address step); → Product Detail (tap line item).
- **Widgets:** `CartLineItem`, `QuantityStepper`, `PromoCodeField`, `CartSummaryPanel`.
- **API Dependencies:** `GetCartSummary`, `UpdateCartItemQuantity`, `RemoveFromCart`, `ApplyPromoCode`, `RemovePromoCode`.
- **Mock Data:** Session-persisted cart; seeded promo codes for QA.
- **Edge Cases:** Empty cart (empty state, "Start Shopping" CTA); item quantity exceeding new stock level at revisit (auto-adjust with notice); expired promo code applied previously (auto-remove with notice).
- **Permissions:** AUTH or PUBLIC-with-guest-cart per flag.
- **Responsive:** RESP-DETAIL (with sticky summary panel on tablet/desktop — see RESP-DETAIL side-panel variant).
- **Admin Behaviour:** N/A.

---

## H. Checkout

### Address Selection / Entry
- **Purpose:** Choose or add a shipping/billing address.
- **User Type:** AUTH.
- **Nav Entry:** Cart → "Checkout" action.
- **Nav Exit:** → Shipping & Payment Method step; → Add/Edit Address form (modal or inline).
- **Widgets:** `AddressCard`, `AddressForm`, `StepperHeader`.
- **API Dependencies:** `GetSavedAddresses`, `SaveAddress`.
- **Mock Data:** Demo user's saved addresses (shared with Profile's Address Book).
- **Edge Cases:** No saved addresses (form shown directly, no empty-list flash); invalid postal code format.
- **Permissions:** AUTH.
- **Responsive:** RESP-WIZARD.
- **Admin Behaviour:** N/A.

### Shipping & Payment Method
- **Purpose:** Choose delivery speed and payment method.
- **User Type:** AUTH.
- **Nav Entry:** Address step (next).
- **Nav Exit:** → Order Review step; → Add Payment Method (inline modal, preserves wizard state).
- **Widgets:** `ShippingMethodTile`, `PaymentMethodTile`, `StepperHeader`.
- **API Dependencies:** `GetShippingMethods`, `CalculateShippingCost`, `GetPaymentMethods`.
- **Mock Data:** 2–3 seeded shipping methods, demo user's saved payment methods.
- **Edge Cases:** No payment method saved (must add one or select COD if enabled); shipping unavailable to selected address (mock rule for a specific seeded postal code, to exercise this state).
- **Permissions:** AUTH.
- **Responsive:** RESP-WIZARD.
- **Admin Behaviour:** N/A.

### Order Review
- **Purpose:** Final confirmation of items, address, shipping, payment, and total before placing the order.
- **User Type:** AUTH.
- **Nav Entry:** Shipping & Payment step (next).
- **Nav Exit:** → Order Confirmation (on place-order success); back to any prior step (edit).
- **Widgets:** `OrderSummaryPanel`, `StepperHeader`, place-order button (loading/disabled during submission).
- **API Dependencies:** `PlaceOrder`.
- **Mock Data:** N/A (composes prior step state).
- **Edge Cases:** Price/stock changed since cart (re-validation before placing, with a blocking notice if changed); double-submit prevented (button disabled post-tap).
- **Permissions:** AUTH.
- **Responsive:** RESP-WIZARD.
- **Admin Behaviour:** N/A.

### Order Confirmation
- **Purpose:** Success acknowledgment with order reference.
- **User Type:** AUTH.
- **Nav Entry:** Order Review, on success only (route replaces stack, not reachable via back button).
- **Nav Exit:** → Order Detail; → Home ("Continue Shopping").
- **Widgets:** Success illustration, order number, `OrderSummaryPanel` (read-only).
- **API Dependencies:** None (reads the just-created order by id).
- **Mock Data:** N/A.
- **Edge Cases:** Direct deep link without a valid just-placed order id → redirect to Order History, not an error page.
- **Permissions:** AUTH.
- **Responsive:** RESP-DETAIL.
- **Admin Behaviour:** N/A.

---

## I. Orders

### Order History
- **Purpose:** List the customer's past and current orders.
- **User Type:** AUTH.
- **Nav Entry:** Shell nav / Profile menu, Order Confirmation ("View All Orders").
- **Nav Exit:** → Order Detail.
- **Widgets:** `OrderListTile`, `OrderStatusBadge`, pagination loader.
- **API Dependencies:** `GetOrders`.
- **Mock Data:** Demo user pre-seeded across all statuses.
- **Edge Cases:** No orders yet (empty state, "Start Shopping" CTA).
- **Permissions:** AUTH.
- **Responsive:** RESP-LIST.
- **Admin Behaviour:** N/A (Admin equivalent is Order Management List, section K).

### Order Detail (with Tracking)
- **Purpose:** Full order info and status timeline.
- **User Type:** AUTH.
- **Nav Entry:** Order History, Order Confirmation, Notification tap.
- **Nav Exit:** → Cancel/Return flow (if eligible); → Product Detail ("buy again" per line item); → Support Contact ("need help with this order").
- **Widgets:** `OrderTrackingTimeline`, `OrderStatusBadge`, line-item list.
- **API Dependencies:** `GetOrderDetail`, `GetOrderTrackingEvents`.
- **Mock Data:** Per-status seeded tracking event sequences.
- **Edge Cases:** Order id no longer exists (edge/test data only) → graceful not-found state, not a crash.
- **Permissions:** AUTH (own orders only).
- **Responsive:** RESP-DETAIL.
- **Admin Behaviour:** N/A.

### Cancel / Return Flow
- **Purpose:** Let an eligible order be cancelled or a return requested.
- **User Type:** AUTH.
- **Nav Entry:** Order Detail action button (only rendered when status allows).
- **Nav Exit:** Back to Order Detail (updated status) on success.
- **Widgets:** `CancelReturnDialog` (reason selection + confirmation).
- **API Dependencies:** `CancelOrder`, `RequestReturn`.
- **Mock Data:** N/A.
- **Edge Cases:** Status changes (e.g., shipped) between opening Order Detail and confirming cancellation — re-validated server-side (mock) before applying.
- **Permissions:** AUTH.
- **Responsive:** RESP-FORM (modal on all breakpoints).
- **Admin Behaviour:** N/A.

---

## J. Payments

### Saved Payment Methods
- **Purpose:** Manage stored (mock) payment methods.
- **User Type:** AUTH.
- **Nav Entry:** Profile/Settings menu; Checkout ("Manage payment methods").
- **Nav Exit:** → Add Payment Method.
- **Widgets:** `PaymentMethodCard`, `PaymentBrandIcon`, default-method indicator.
- **API Dependencies:** `GetPaymentMethods`, `RemovePaymentMethod`, `SetDefaultPaymentMethod`.
- **Mock Data:** Demo user's seeded masked methods.
- **Edge Cases:** Removing the only/default method (must set a new default or block removal with explanation).
- **Permissions:** AUTH.
- **Responsive:** RESP-LIST.
- **Admin Behaviour:** N/A.

### Add Payment Method
- **Purpose:** Add a new (mock) payment method.
- **User Type:** AUTH.
- **Nav Entry:** Saved Payment Methods, Checkout inline modal.
- **Nav Exit:** Back to origin screen with new method available.
- **Widgets:** `AddCardForm` (Luhn-validated), `PaymentBrandIcon` (live detection from number prefix).
- **API Dependencies:** `AddPaymentMethod`.
- **Mock Data:** N/A (session-only mock storage, masked immediately after entry).
- **Edge Cases:** Invalid card number/expiry/CVV format (inline validation, never submitted).
- **Permissions:** AUTH.
- **Responsive:** RESP-FORM.
- **Admin Behaviour:** N/A.

---

## K. Notifications

### Notification Center
- **Purpose:** Central feed of order/marketing/system notifications.
- **User Type:** AUTH.
- **Nav Entry:** Shell bell icon.
- **Nav Exit:** → related entity (e.g., Order Detail) per notification; → Notification Preferences.
- **Widgets:** `NotificationTile`, `NotificationCategoryFilterChip`, `UnreadBadge`.
- **API Dependencies:** `GetNotifications`, `MarkAsRead`, `MarkAllAsRead`.
- **Mock Data:** Mixed read/unread seeded set.
- **Edge Cases:** Notification referencing a deleted/unavailable entity (graceful fallback, not a broken link); zero notifications (empty state).
- **Permissions:** AUTH.
- **Responsive:** RESP-LIST.
- **Admin Behaviour:** Admin app has its own notification center scoped to operational alerts (e.g., low stock, new order) — same screen pattern, different data source.

### Notification Preferences
- **Purpose:** Toggle notification categories on/off.
- **User Type:** AUTH.
- **Nav Entry:** Notification Center, Settings.
- **Nav Exit:** Back to origin.
- **Widgets:** `SettingsToggleTile` per category.
- **API Dependencies:** `GetNotificationPreferences`, `UpdateNotificationPreferences`.
- **Mock Data:** Default all-on state.
- **Edge Cases:** Disabling all categories still allows critical order-status notifications if tenant policy marks them non-optional.
- **Permissions:** AUTH.
- **Responsive:** RESP-FORM.
- **Admin Behaviour:** N/A.

---

## L. Profile

### Profile Overview
- **Purpose:** Account hub linking to edit profile, address book, orders, settings.
- **User Type:** AUTH.
- **Nav Entry:** Bottom nav "Profile"/"Account" tab.
- **Nav Exit:** → Edit Profile, → Address Book, → Order History, → Settings, → Support, → Logout.
- **Widgets:** `ProfileHeader`, `ProfileMenuTile`.
- **API Dependencies:** `GetProfile`.
- **Mock Data:** Demo user profile.
- **Edge Cases:** Avatar image failed to load (initials fallback).
- **Permissions:** AUTH.
- **Responsive:** RESP-LIST.
- **Admin Behaviour:** N/A (Admin has role badge + logout in shell header instead).

### Edit Profile
- **Purpose:** Update name/email/phone/avatar.
- **User Type:** AUTH.
- **Nav Entry:** Profile Overview.
- **Nav Exit:** Back to Profile Overview on save.
- **Widgets:** `AuthTextField` (reused), avatar picker (mock).
- **API Dependencies:** `UpdateProfile`.
- **Mock Data:** N/A.
- **Edge Cases:** Changing email requires re-verification (OTP flow reuse) if tenant policy requires it.
- **Permissions:** AUTH.
- **Responsive:** RESP-FORM.
- **Admin Behaviour:** N/A.

### Address Book
- **Purpose:** List saved addresses.
- **User Type:** AUTH.
- **Nav Entry:** Profile Overview.
- **Nav Exit:** → Add/Edit Address.
- **Widgets:** `AddressCard`, default-address indicator.
- **API Dependencies:** `GetAddresses`, `DeleteAddress`, `SetDefaultAddress`.
- **Mock Data:** Demo user's seeded addresses.
- **Edge Cases:** Deleting an address referenced by an active order is blocked with explanation.
- **Permissions:** AUTH.
- **Responsive:** RESP-LIST.
- **Admin Behaviour:** N/A.

### Add / Edit Address
- **Purpose:** Create or modify an address (shared with Checkout).
- **User Type:** AUTH.
- **Nav Entry:** Address Book, Checkout Address step.
- **Nav Exit:** Back to origin with updated list.
- **Widgets:** `AddressForm`.
- **API Dependencies:** `AddAddress`, `UpdateAddress`.
- **Mock Data:** N/A.
- **Edge Cases:** Invalid postal/zip format per shared validators.
- **Permissions:** AUTH.
- **Responsive:** RESP-FORM.
- **Admin Behaviour:** N/A.

---

## M. Settings

### Settings
- **Purpose:** App-level preferences hub.
- **User Type:** AUTH.
- **Nav Entry:** Profile Overview.
- **Nav Exit:** → Change Password, → Security Settings, theme/language inline controls.
- **Widgets:** `SettingsSectionHeader`, `SettingsToggleTile`, `SettingsNavigationTile`, `LanguagePickerSheet`.
- **API Dependencies:** `GetAppSettings`, `UpdateThemeMode`, `UpdateLocale`.
- **Mock Data:** Default settings, persisted locally after change.
- **Edge Cases:** Locale with incomplete translation falls back to default locale strings, never a blank label.
- **Permissions:** AUTH.
- **Responsive:** RESP-LIST.
- **Admin Behaviour:** Admin app has an equivalent Settings screen (theme + account security only; no locale/notification prefs unless tenant enables it).

### Change Password
- **Purpose:** Update account password.
- **User Type:** AUTH.
- **Nav Entry:** Settings.
- **Nav Exit:** Back to Settings on success.
- **Widgets:** `AuthTextField`, `PasswordStrengthIndicator`.
- **API Dependencies:** `ChangePassword`.
- **Mock Data:** N/A.
- **Edge Cases:** Incorrect current password; new password fails strength policy.
- **Permissions:** AUTH.
- **Responsive:** RESP-FORM.
- **Admin Behaviour:** Shared pattern for admin users.

### Security Settings
- **Purpose:** Biometric login toggle, active sessions (placeholder), account deletion request.
- **User Type:** AUTH.
- **Nav Entry:** Settings.
- **Nav Exit:** Back to Settings.
- **Widgets:** `SettingsToggleTile`.
- **API Dependencies:** `ToggleBiometricLogin`.
- **Mock Data:** Default off.
- **Edge Cases:** Biometric toggle on a device/platform without biometric hardware (Web) is hidden, not shown disabled.
- **Permissions:** AUTH.
- **Responsive:** RESP-LIST.
- **Admin Behaviour:** N/A.

---

## N. Support

### Help Center / FAQ
- **Purpose:** Self-service answers.
- **User Type:** PUBLIC/AUTH.
- **Nav Entry:** Profile/Settings menu, shell help icon.
- **Nav Exit:** → Contact/Create Ticket ("still need help").
- **Widgets:** `FaqAccordionTile`, `FaqCategoryTab`, search field.
- **API Dependencies:** `GetFaqItems`, `SearchFaq`.
- **Mock Data:** ≥15 seeded FAQ entries.
- **Edge Cases:** No search results (empty state + "Contact Us" CTA).
- **Permissions:** PUBLIC.
- **Responsive:** RESP-DETAIL.
- **Admin Behaviour:** N/A.

### Contact / Create Ticket
- **Purpose:** Submit a support request.
- **User Type:** AUTH (guest may be allowed via email field per tenant flag).
- **Nav Entry:** Help Center, Order Detail ("need help").
- **Nav Exit:** → Ticket Status on submit.
- **Widgets:** `TicketForm`.
- **API Dependencies:** `CreateSupportTicket`.
- **Mock Data:** N/A.
- **Edge Cases:** Missing required fields blocked pre-submit.
- **Permissions:** AUTH or PUBLIC per flag.
- **Responsive:** RESP-FORM.
- **Admin Behaviour:** N/A (admin-side ticket queue is a documented future enhancement, not in Phase 1 scope).

### Ticket Status
- **Purpose:** View submitted ticket(s) and their status.
- **User Type:** AUTH.
- **Nav Entry:** Contact/Create Ticket (post-submit), "My Tickets" list.
- **Nav Exit:** Back to Help Center.
- **Widgets:** `TicketStatusBadge`, message thread (read-only in Phase 1).
- **API Dependencies:** `GetMyTickets`, `GetTicketDetail`.
- **Mock Data:** Demo user pre-seeded with one in-progress ticket.
- **Edge Cases:** Zero tickets (empty state).
- **Permissions:** AUTH.
- **Responsive:** RESP-DETAIL.
- **Admin Behaviour:** N/A.

---

## O. Admin Access Control

### Access Denied
- **Purpose:** Explain and redirect when an admin lacks permission for a requested route.
- **User Type:** Authenticated admin, wrong role.
- **Nav Entry:** Router guard redirect (direct URL entry, stale nav link).
- **Nav Exit:** → Admin Dashboard (role-appropriate landing).
- **Widgets:** `AccessDeniedView`.
- **API Dependencies:** None.
- **Mock Data:** N/A.
- **Edge Cases:** N/A.
- **Permissions:** ADMIN:ANY (shown to any admin lacking the specific required permission).
- **Responsive:** RESP-DETAIL.
- **Admin Behaviour:** Core admin-only screen.

---

## P. Admin Dashboard & Analytics

### Admin Dashboard
- **Purpose:** At-a-glance KPIs.
- **User Type:** ADMIN:ANY (content scoped/filtered per role where relevant).
- **Nav Entry:** Admin app post-login default.
- **Nav Exit:** → Analytics Detail, → Reports, → Order Management, → Catalog Management.
- **Widgets:** `KpiCard`, `LineChartCard`, `TopProductsTable`.
- **API Dependencies:** `GetDashboardKpis`, `GetSalesTrend`, `GetTopProducts`.
- **Mock Data:** Deterministically derived from seeded Orders/Products.
- **Edge Cases:** Zero-data state (new/demo tenant) shows explanatory empty charts, not broken axes.
- **Permissions:** ADMIN:ANY.
- **Responsive:** RESP-DASH.
- **Desktop Behaviour:** Persistent side nav + multi-column KPI grid.
- **Tablet Behaviour:** Collapsible side nav (drawer) + 2-column KPI grid.
- **Admin Behaviour:** This entire screen is admin-exclusive by definition.

### Analytics Detail
- **Purpose:** Drill into a specific KPI/trend.
- **User Type:** ADMIN:ANY.
- **Nav Entry:** Admin Dashboard (tap a KPI card/chart).
- **Nav Exit:** Back to Dashboard.
- **Widgets:** `BarChartCard`, `LineChartCard`, date-range picker.
- **API Dependencies:** `GetSalesTrend` (parameterized).
- **Mock Data:** Same as Dashboard.
- **Edge Cases:** Date range with no orders.
- **Permissions:** ADMIN:ANY.
- **Responsive:** RESP-DASH.
- **Admin Behaviour:** Admin-exclusive.

### Reports
- **Purpose:** Generate/view tabular business reports.
- **User Type:** ADMIN:ANY.
- **Nav Entry:** Admin shell side nav.
- **Nav Exit:** N/A (terminal screen, mock export action).
- **Widgets:** `ReportExportButton`, paginated table.
- **API Dependencies:** `GenerateReport`.
- **Mock Data:** Derived report rows.
- **Edge Cases:** Report with zero rows (empty state, still offers export of empty template).
- **Permissions:** ADMIN:ANY.
- **Responsive:** RESP-TABLE.
- **Admin Behaviour:** Admin-exclusive.

---

## Q. Admin Catalog & Inventory

### Product Management List
- **Purpose:** Browse/manage all products.
- **User Type:** ADMIN:CatalogManager.
- **Nav Entry:** Admin shell side nav → Catalog → Products.
- **Nav Exit:** → Product Create/Edit; → Inventory (per-row "Adjust Stock" action).
- **Widgets:** `AdminDataTable`, `BulkActionToolbar`.
- **API Dependencies:** `GetProducts` (admin-scoped, includes inactive/draft products).
- **Mock Data:** Shared with storefront Products.
- **Edge Cases:** Zero products (empty state with "Create Product" CTA).
- **Permissions:** ADMIN:CatalogManager.
- **Responsive:** RESP-TABLE.
- **Admin Behaviour:** Admin-exclusive; bulk select + bulk status update.

### Product Create / Edit
- **Purpose:** Author or modify a product and its variants.
- **User Type:** ADMIN:CatalogManager.
- **Nav Entry:** Product Management List.
- **Nav Exit:** Back to list on save; discard-confirmation on cancel with unsaved changes.
- **Widgets:** `ProductForm`, `ImageUploaderMock`, variant editor rows.
- **API Dependencies:** `CreateProduct`, `UpdateProduct`.
- **Mock Data:** Mutates shared in-memory product store.
- **Edge Cases:** Missing required fields (inline validation); duplicate SKU.
- **Permissions:** ADMIN:CatalogManager.
- **Responsive:** RESP-FORM (wide variant on desktop with two-column field layout).
- **Admin Behaviour:** Admin-exclusive.

### Category Management List
- **Purpose:** Browse/manage the category tree.
- **User Type:** ADMIN:CatalogManager.
- **Nav Entry:** Admin shell side nav → Catalog → Categories.
- **Nav Exit:** → Category Create/Edit.
- **Widgets:** `AdminDataTable` (tree-aware, indentation), drag-to-reorder.
- **API Dependencies:** `GetCategoryTree` (admin-scoped), `ReorderCategories`.
- **Mock Data:** Shared with storefront Categories.
- **Edge Cases:** Reordering across parent boundaries.
- **Permissions:** ADMIN:CatalogManager.
- **Responsive:** RESP-TABLE.
- **Admin Behaviour:** Admin-exclusive.

### Category Create / Edit
- **Purpose:** Author or modify a category node.
- **User Type:** ADMIN:CatalogManager.
- **Nav Entry:** Category Management List.
- **Nav Exit:** Back to list on save.
- **Widgets:** `CategoryForm`, parent-category selector.
- **API Dependencies:** `CreateCategory`, `UpdateCategory`.
- **Mock Data:** Mutates shared category tree.
- **Edge Cases:** Deleting a category with children/products blocked with explanation (handled from the list screen's delete action, validated here on parent reassignment).
- **Permissions:** ADMIN:CatalogManager.
- **Responsive:** RESP-FORM.
- **Admin Behaviour:** Admin-exclusive.

### Inventory Overview
- **Purpose:** View stock levels across the catalog.
- **User Type:** ADMIN:CatalogManager.
- **Nav Entry:** Admin shell side nav → Inventory.
- **Nav Exit:** → Stock Adjustment; → Low Stock Alerts.
- **Widgets:** `StockLevelTable`, `LowStockBadge`.
- **API Dependencies:** `GetStockLevels`.
- **Mock Data:** Derived from seeded product stock fields.
- **Edge Cases:** Zero-stock items visually distinct from low-stock items.
- **Permissions:** ADMIN:CatalogManager.
- **Responsive:** RESP-TABLE.
- **Admin Behaviour:** Admin-exclusive.

### Stock Adjustment
- **Purpose:** Manually adjust a product/variant's stock quantity with an audit reason.
- **User Type:** ADMIN:CatalogManager.
- **Nav Entry:** Inventory Overview, Product Management List row action.
- **Nav Exit:** Back to origin with updated quantity.
- **Widgets:** `StockAdjustmentDialog`.
- **API Dependencies:** `AdjustStock`.
- **Mock Data:** N/A (mutates stock level, appends `StockAdjustment` audit record).
- **Edge Cases:** Negative resulting quantity blocked.
- **Permissions:** ADMIN:CatalogManager.
- **Responsive:** RESP-FORM (modal).
- **Admin Behaviour:** Admin-exclusive.

### Low Stock Alerts
- **Purpose:** Surface items below threshold.
- **User Type:** ADMIN:CatalogManager.
- **Nav Entry:** Inventory Overview, Admin Dashboard alert widget.
- **Nav Exit:** → Stock Adjustment.
- **Widgets:** `StockLevelTable` (filtered), `LowStockBadge`.
- **API Dependencies:** `GetLowStockItems`, `SetLowStockThreshold`.
- **Mock Data:** Subset of seeded products below threshold.
- **Edge Cases:** Zero alerts (positive empty state, "all stocked" message).
- **Permissions:** ADMIN:CatalogManager.
- **Responsive:** RESP-TABLE.
- **Admin Behaviour:** Admin-exclusive.

---

## R. Admin Orders & Customers

### Order Management List
- **Purpose:** Browse/filter all customer orders.
- **User Type:** ADMIN:OrderManager.
- **Nav Entry:** Admin shell side nav → Orders.
- **Nav Exit:** → Order Management Detail.
- **Widgets:** `AdminOrderTable`, status/date filters.
- **API Dependencies:** `GetAllOrders`.
- **Mock Data:** Shared with customer Orders, across multiple mock customers.
- **Edge Cases:** No orders matching filter (empty state, "clear filters" affordance).
- **Permissions:** ADMIN:OrderManager.
- **Responsive:** RESP-TABLE.
- **Admin Behaviour:** Admin-exclusive.

### Order Management Detail
- **Purpose:** Full order detail with admin actions.
- **User Type:** ADMIN:OrderManager.
- **Nav Entry:** Order Management List, Customer Detail (linked order).
- **Nav Exit:** Back to list; → Customer Detail (linked customer).
- **Widgets:** `OrderStatusDropdown`, `RefundDialog`, `OrderNoteThread`.
- **API Dependencies:** `UpdateOrderStatus`, `IssueRefund`, `AddOrderNote`.
- **Mock Data:** N/A.
- **Edge Cases:** Illegal status transition prevented at the dropdown level (not just rejected).
- **Permissions:** ADMIN:OrderManager.
- **Responsive:** RESP-DETAIL.
- **Admin Behaviour:** Admin-exclusive.

### Customer List
- **Purpose:** Browse/search customer accounts.
- **User Type:** ADMIN:OrderManager or ADMIN:SuperAdmin (customer PII sensitivity — role documented for review at implementation time).
- **Nav Entry:** Admin shell side nav → Customers.
- **Nav Exit:** → Customer Detail.
- **Widgets:** `CustomerTable`, search field.
- **API Dependencies:** `GetCustomers`.
- **Mock Data:** ≥10 seeded customers.
- **Edge Cases:** No search matches (empty state).
- **Permissions:** ADMIN:OrderManager.
- **Responsive:** RESP-TABLE.
- **Admin Behaviour:** Admin-exclusive.

### Customer Detail
- **Purpose:** Full customer profile, order history, notes, account actions.
- **User Type:** ADMIN:OrderManager.
- **Nav Entry:** Customer List, Order Management Detail (linked customer).
- **Nav Exit:** → Order Management Detail (linked order); back to list.
- **Widgets:** `CustomerProfilePanel`, `CustomerOrderHistoryList`, `CustomerNoteThread`, `SuspendConfirmationDialog`.
- **API Dependencies:** `GetCustomerDetail`, `SuspendCustomer`, `ReactivateCustomer`, `AddCustomerNote`.
- **Mock Data:** N/A.
- **Edge Cases:** Suspending a customer with an in-progress order (warning shown, action still allowed per policy).
- **Permissions:** ADMIN:OrderManager (suspend/reactivate may be restricted to ADMIN:SuperAdmin — confirm at implementation).
- **Responsive:** RESP-DETAIL.
- **Admin Behaviour:** Admin-exclusive.

---

## S. Marketing

### Promotions List
- **Purpose:** Browse/manage coupons and promotions.
- **User Type:** ADMIN:MarketingManager.
- **Nav Entry:** Admin shell side nav → Marketing → Promotions.
- **Nav Exit:** → Promotion Create/Edit.
- **Widgets:** `PromotionTable`.
- **API Dependencies:** `ValidateCoupon` (read/status), list query.
- **Mock Data:** 3–5 seeded coupons (valid/expired/exhausted mix).
- **Edge Cases:** Expired/exhausted coupons visually flagged, not hidden.
- **Permissions:** ADMIN:MarketingManager.
- **Responsive:** RESP-TABLE.
- **Admin Behaviour:** Admin-exclusive.

### Promotion Create / Edit
- **Purpose:** Author/modify a coupon.
- **User Type:** ADMIN:MarketingManager.
- **Nav Entry:** Promotions List.
- **Nav Exit:** Back to list on save.
- **Widgets:** `PromotionForm`.
- **API Dependencies:** `CreateCoupon`, `UpdateCoupon`, `DeactivateCoupon`.
- **Mock Data:** Mutates shared coupon store consumed by Cart.
- **Edge Cases:** Overlapping/duplicate code blocked.
- **Permissions:** ADMIN:MarketingManager.
- **Responsive:** RESP-FORM.
- **Admin Behaviour:** Admin-exclusive.

### Banner Management
- **Purpose:** Manage storefront Home banners.
- **User Type:** ADMIN:MarketingManager.
- **Nav Entry:** Admin shell side nav → Marketing → Banners.
- **Nav Exit:** N/A (inline create/edit via `BannerForm` modal).
- **Widgets:** `BannerManagerList`, `BannerForm`, `BannerPreview`.
- **API Dependencies:** `CreateBanner`, `UpdateBanner`, `ReorderBanners`.
- **Mock Data:** 3 seeded banners.
- **Edge Cases:** Banner with expired active-window still editable but not shown on storefront.
- **Permissions:** ADMIN:MarketingManager.
- **Responsive:** RESP-TABLE with inline `BannerPreview`.
- **Admin Behaviour:** Admin-exclusive.

---

## T. White-Label / Tenant Management

### Tenant Profile
- **Purpose:** View/edit core tenant identity (name, domain, contact info, default locale).
- **User Type:** ADMIN:SuperAdmin.
- **Nav Entry:** Admin shell side nav → Tenant → Profile.
- **Nav Exit:** → Branding Editor, → Feature Flag Manager.
- **Widgets:** Standard form fields.
- **API Dependencies:** `GetTenantConfig`, `UpdateTenantCopy`.
- **Mock Data:** `default_tenant` config.
- **Edge Cases:** N/A.
- **Permissions:** ADMIN:SuperAdmin.
- **Responsive:** RESP-FORM.
- **Admin Behaviour:** Admin-exclusive, highest-privilege screen group.

### Branding Editor
- **Purpose:** Edit colors/logo/typography with live preview.
- **User Type:** ADMIN:SuperAdmin.
- **Nav Entry:** Tenant Profile.
- **Nav Exit:** Back to Tenant Profile on save.
- **Widgets:** `BrandingColorPicker`, `LogoUploaderMock`, `LivePreviewPane`.
- **API Dependencies:** `UpdateTenantBranding`.
- **Mock Data:** N/A (mutates active `TenantConfig` in-memory + persisted mock store).
- **Edge Cases:** Insufficient color contrast between chosen brand colors (warning shown, not blocked).
- **Permissions:** ADMIN:SuperAdmin.
- **Responsive:** RESP-DETAIL side-panel (editor + live preview split on tablet/desktop; stacked on mobile).
- **Admin Behaviour:** Admin-exclusive.

### Feature Flag Manager
- **Purpose:** Enable/disable features per tenant.
- **User Type:** ADMIN:SuperAdmin.
- **Nav Entry:** Tenant Profile.
- **Nav Exit:** Back to Tenant Profile.
- **Widgets:** `FeatureFlagToggleRow`.
- **API Dependencies:** `ToggleFeatureFlag`.
- **Mock Data:** Default flag set (all enabled).
- **Edge Cases:** Disabling a flag with dependent features (e.g., disabling Wishlist while it's referenced elsewhere) shows a dependency warning.
- **Permissions:** ADMIN:SuperAdmin.
- **Responsive:** RESP-LIST.
- **Admin Behaviour:** Admin-exclusive.

### Tenant Switcher (DEV)
- **Purpose:** Switch active tenant for demo/QA without rebuilding.
- **User Type:** DEV.
- **Nav Entry:** Admin shell side nav (visible only in `dev`/`staging` flavors).
- **Nav Exit:** Reloads app shell with new `TenantConfig`.
- **Widgets:** Tenant picker list.
- **API Dependencies:** `CreateTenant`, `SwitchActiveTenant`.
- **Mock Data:** `default_tenant` + one demo tenant.
- **Edge Cases:** N/A.
- **Permissions:** DEV (absent entirely from production route table).
- **Responsive:** RESP-LIST.
- **Admin Behaviour:** Admin-exclusive, non-production only.

---

## U. Developer Panel

### Developer Panel
- **Purpose:** QA/demo acceleration utilities.
- **User Type:** DEV.
- **Nav Entry:** Hidden menu entry / gesture, non-production flavors only.
- **Nav Exit:** N/A (utility screen, no forward flow).
- **Widgets:** `DevPanelSection`, `MockDataResetButton`, `EnvironmentSwitcherDropdown`.
- **API Dependencies:** `ResetMockData`, `SwitchEnvironment`, `SimulateNotification`.
- **Mock Data:** Acts on all features' mock stores.
- **Edge Cases:** N/A.
- **Permissions:** DEV.
- **Responsive:** RESP-LIST.
- **Admin Behaviour:** Present in both apps identically, non-production only.

---

## V. System / Fallback Screens

### 404 Not Found
- **Purpose:** Graceful handling of unmatched routes.
- **User Type:** Anyone.
- **Nav Entry:** Router `errorBuilder` for any unmatched path.
- **Nav Exit:** → Home/Admin Dashboard (contextual "Go Back" CTA).
- **Widgets:** Illustration, message, CTA button.
- **API Dependencies:** None.
- **Mock Data:** N/A.
- **Edge Cases:** N/A.
- **Permissions:** PUBLIC.
- **Responsive:** RESP-DETAIL.
- **Admin Behaviour:** Admin app has its own 404 pointing back to Admin Dashboard.

### Maintenance Mode
- **Purpose:** Full-app takeover screen when a tenant/environment is flagged under maintenance.
- **User Type:** Anyone.
- **Nav Entry:** Router redirect-all when `AppConfig.maintenanceMode == true`.
- **Nav Exit:** None (blocks all navigation until flag clears; auto-retry poll).
- **Widgets:** Illustration, tenant-configurable message, estimated-return time (optional).
- **API Dependencies:** None (reads local `AppConfig`/`TenantConfig` state).
- **Mock Data:** N/A.
- **Edge Cases:** Admin app should generally remain accessible during customer-app maintenance (separate flags per app — documented in `11_ENVIRONMENT_CONFIGURATION.md`).
- **Permissions:** PUBLIC.
- **Responsive:** RESP-DETAIL.
- **Admin Behaviour:** Admin app has an independent maintenance flag from the storefront.
