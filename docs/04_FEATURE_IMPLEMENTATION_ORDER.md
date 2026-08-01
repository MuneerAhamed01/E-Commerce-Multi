# 04 — Feature Implementation Order

**Status:** Planning document. Every production feature, fully specified, listed strictly in dependency order. No feature below depends on a feature listed after it.

This document is the contract layer between `03_DEVELOPMENT_PHASES.md` (the *when*) and `07_SCREEN_CATALOG.md` / `08_COMPONENT_LIBRARY.md` / `09_ROUTING_PLAN.md` (the *what*, screen-by-screen and component-by-component).

---

## 1. Authentication

**Package:** `packages/features/authentication`

- **Purpose:** Establish and persist user identity for both customer and admin apps; gate every protected route.
- **Dependencies:** `core` (Result, UseCase, DI), `design_system` (form fields, buttons).
- **Screens:** Splash, Onboarding (first-run only), Login, Register, Forgot Password, OTP Verification.
- **Business Logic (Use Cases):** `LoginUser`, `RegisterUser`, `LogoutUser`, `RequestPasswordReset`, `VerifyOtp`, `GetCurrentUser`, `RefreshSession`.
- **Repositories:** `AuthRepository` (interface) → `MockAuthRepositoryImpl` (active) / `FirebaseAuthRepositoryImpl` (future, stubbed).
- **Models/Entities:** `User`, `AuthSession`, `AuthCredentials` (DTO only, never persisted as entity).
- **Routes:** `/splash`, `/onboarding`, `/login`, `/register`, `/forgot-password`, `/verify-otp`.
- **Widgets:** `AuthTextField`, `PasswordStrengthIndicator`, `OtpInputRow`, `AuthPrimaryButton` (composed from design-system `AppTextField`/`AppButton`).
- **Mock Data:** Seeded mock user set (`mock_users.dart`) covering at least one customer and one admin-role user per `AdminRole` value.
- **State Management:** `AuthBloc` (session lifecycle: unauthenticated/authenticating/authenticated/error) + `LoginCubit`/`RegisterCubit` for form-local state.
- **Navigation:** Splash → Onboarding (first run) or Login (returning) → Login/Register ↔ Forgot Password → OTP → authenticated shell (Home or Admin Dashboard depending on app/role).
- **Acceptance Criteria:** Registration creates a session; invalid credentials show inline error, not a generic dialog; logout clears persisted session and route guard immediately redirects to Login; app restart with a valid persisted session skips Login.

---

## 2. Dashboard / Home

**Package:** `packages/features/dashboard` (customer Home); admin dashboard is `packages/features/admin_dashboard` (see §15).

- **Purpose:** Post-login landing surface for the customer app; entry point to catalog browsing.
- **Dependencies:** Authentication (session), Products/Categories domains (for featured content — read-only use case call, not UI coupling).
- **Screens:** Home.
- **Business Logic:** `GetHomeFeed` (aggregates banners, featured categories, featured products from respective repositories).
- **Repositories:** No new repository; composes existing `ProductRepository`, `CategoryRepository`, and a `BannerRepository` (owned by `marketing` feature domain, consumed here — documented cross-feature domain dependency).
- **Models:** `HomeFeed` (aggregate view model, not persisted).
- **Routes:** `/home` (shell branch root for authenticated customer app).
- **Widgets:** `BannerCarousel`, `FeaturedCategoryRow`, `FeaturedProductRow`.
- **Mock Data:** Reuses Products/Categories/Marketing fixtures; no independent fixture set of its own beyond banner ordering.
- **State Management:** `HomeBloc`.
- **Navigation:** Bottom-nav root → Product listing / Category browse / Search / Cart (via shell nav, not push).
- **Acceptance Criteria:** Home loads within mock-latency budget with skeleton loading state; empty state shown gracefully if no featured content configured for the active tenant; tapping a banner/product navigates correctly.

---

## 3. Products

**Package:** `packages/features/products`

- **Purpose:** Core catalog: browse, view detail, read/write reviews. Domain is reused by Admin Catalog (§17).
- **Dependencies:** Authentication (optional — browsing allowed unauthenticated per §9 Routing Plan public routes), Wishlist (read-only toggle state, integration point).
- **Screens:** Product Listing, Product Detail.
- **Business Logic:** `GetProducts` (paginated, filterable), `GetProductDetail`, `GetRelatedProducts`, `SubmitProductReview`, `GetProductReviews`.
- **Repositories:** `ProductRepository` → `MockProductRepositoryImpl`.
- **Models:** `Product`, `ProductVariant`, `ProductImage`, `Review`.
- **Routes:** `/products`, `/products/:productId`.
- **Widgets:** `ProductCard`, `ProductGrid`, `VariantSelector`, `ProductGallery`, `ReviewList`, `ReviewSubmissionForm`, `RatingSummary`.
- **Mock Data:** ≥50 seeded products across ≥6 categories, with multi-variant examples and pre-seeded reviews.
- **State Management:** `ProductListBloc` (pagination + filter state), `ProductDetailBloc` (variant selection, stock check), `ReviewsCubit`.
- **Navigation:** Listing → Detail (push); Detail → Cart (add-to-cart action, no navigation) / Wishlist (toggle, no navigation) / Related product (push, replaces detail params).
- **Acceptance Criteria:** List paginates without duplicate/missing items; out-of-stock variants are selectable but block add-to-cart with a clear message; review submission requires authentication (unauthenticated tap routes to Login with return-to redirect).

---

## 4. Categories

**Package:** `packages/features/categories`

- **Purpose:** Structured, hierarchical browsing entry point into Products.
- **Dependencies:** Products (reuses listing use case/UI filtered by category).
- **Screens:** Category Browse, Category Detail (= filtered Product Listing).
- **Business Logic:** `GetCategoryTree`, `GetCategoryDetail`.
- **Repositories:** `CategoryRepository` → `MockCategoryRepositoryImpl`.
- **Models:** `Category` (self-referential tree: `parentId`, `children`).
- **Routes:** `/categories`, `/categories/:categoryId`.
- **Widgets:** `CategoryGridTile`, `CategoryBreadcrumb`, `SubcategoryChipRow`.
- **Mock Data:** ≥3-level category tree (e.g., Electronics → Phones → Accessories) with ≥15 total nodes.
- **State Management:** `CategoryTreeCubit`, reuses `ProductListBloc` (parameterized by `categoryId`) for the detail screen.
- **Navigation:** Browse → Detail (push) → Product Detail (push); breadcrumb allows jumping to any ancestor.
- **Acceptance Criteria:** Deep-linking directly to `/categories/:categoryId` resolves without requiring the user to have navigated through Browse first.

---

## 5. Search

**Package:** `packages/features/search`

- **Purpose:** Query-driven product discovery with filters and sort, across the full catalog.
- **Dependencies:** Products, Categories (filter facets).
- **Screens:** Search (entry/suggestions), Search Results.
- **Business Logic:** `SearchProducts` (query + filters + sort, paginated), `GetSearchSuggestions`, `GetRecentSearches`, `SaveRecentSearch`, `ClearRecentSearches`.
- **Repositories:** `SearchRepository` → `MockSearchRepositoryImpl` (may internally delegate to `ProductRepository` for actual matching against mock data). `RecentSearchRepository` (local-only, e.g. `shared_preferences`-backed).
- **Models:** `SearchQuery`, `SearchFilter` (price range, category, rating, availability), `SortOption` (enum: relevance, price asc/desc, newest, rating).
- **Routes:** `/search`, `/search/results`.
- **Widgets:** `SearchBar`, `RecentSearchChip`, `SearchSuggestionTile`, `FilterBottomSheet`, `SortBottomSheet`, `ActiveFilterChipRow`.
- **Mock Data:** Reuses Products fixtures; recent-search list seeded empty by default.
- **State Management:** `SearchBloc` (query text, debounce, suggestions), `SearchResultsBloc` (results + active filters/sort).
- **Navigation:** Search entry (from Home/shell) → type-ahead suggestions (no navigation) → submit → Results (push) → Filter/Sort (modal bottom sheet) → Product Detail (push).
- **Acceptance Criteria:** Input is debounced (≥300ms); empty query with no recent searches shows an empty state with trending/suggested terms; zero-results state is distinct from the loading/error states; filters combine with AND semantics as documented in `10_DATA_FLOW.md`.

---

## 6. Wishlist

**Package:** `packages/features/wishlist`

- **Purpose:** Let authenticated users bookmark products for later.
- **Dependencies:** Authentication (must be logged in), Products (entity reuse for display).
- **Screens:** Wishlist.
- **Business Logic:** `AddToWishlist`, `RemoveFromWishlist`, `GetWishlist`, `IsInWishlist` (used by toggle widgets across the app).
- **Repositories:** `WishlistRepository` → `MockWishlistRepositoryImpl`.
- **Models:** `WishlistItem` (references `productId`, `variantId?`, `addedAt`).
- **Routes:** `/wishlist`.
- **Widgets:** `WishlistToggleButton` (reused inside `products` cards/detail via the barrel export), `WishlistGrid`.
- **Mock Data:** Empty by default per user; demo user pre-seeded with a handful of items for QA convenience.
- **State Management:** `WishlistCubit` (single source of truth for wishlist membership, watched by toggle buttons anywhere in the app).
- **Navigation:** Accessible from shell nav / profile menu → Wishlist screen → Product Detail (push) / remove-in-place (no navigation).
- **Acceptance Criteria:** Toggling from Product Detail and from the Wishlist screen itself stay in sync instantly (single Cubit instance via DI singleton scope); unauthenticated toggle attempt redirects to Login with return-to redirect.

---

## 7. Cart

**Package:** `packages/features/cart`

- **Purpose:** Hold items intended for purchase; compute authoritative pricing; apply promo codes.
- **Dependencies:** Products (price/stock source of truth), Marketing (promo/coupon validation — domain dependency, documented).
- **Screens:** Cart.
- **Business Logic:** `AddToCart`, `UpdateCartItemQuantity`, `RemoveFromCart`, `ClearCart`, `ApplyPromoCode`, `RemovePromoCode`, `GetCartSummary` (subtotal/discount/tax-placeholder/total).
- **Repositories:** `CartRepository` → `MockCartRepositoryImpl` (persists locally so cart survives restart).
- **Models:** `CartItem`, `Cart` (aggregate root), `PricingBreakdown`.
- **Routes:** `/cart`.
- **Widgets:** `CartLineItem`, `QuantityStepper`, `PromoCodeField`, `CartSummaryPanel`, `CartBadge` (shell-level, shown in nav).
- **Mock Data:** Empty by default; a small set of valid/invalid/expired mock promo codes for QA.
- **State Management:** `CartBloc` (full cart lifecycle), exposed cart-count stream consumed by shell-level `CartBadge`.
- **Navigation:** Any "Add to Cart" action (Products/Search/Categories) → no navigation, snackbar confirmation → Cart accessible via shell nav → Checkout (push, requires non-empty cart and authentication).
- **Acceptance Criteria:** Quantity changes respect available stock; removing the last item shows the Cart empty state; invalid/expired promo codes show a specific inline error (not a generic failure); totals recompute deterministically and are covered by unit tests for edge cases (zero, max stock, expired coupon, min-spend not met).

---

## 8. Checkout

**Package:** `packages/features/checkout`

- **Purpose:** Convert a valid, non-empty cart into a placed order.
- **Dependencies:** Cart (source cart), Payments (method selection — minimal contract), Orders (order creation — see sequencing note in `03_DEVELOPMENT_PHASES.md` Phase 14), Profile (address book reuse).
- **Screens:** Address Selection/Entry, Shipping & Payment Method, Order Review, Order Confirmation.
- **Business Logic:** `GetSavedAddresses`, `SaveAddress`, `GetShippingMethods`, `CalculateShippingCost`, `PlaceOrder`.
- **Repositories:** `CheckoutRepository` → `MockCheckoutRepositoryImpl` (shipping methods, checkout session state); reuses `AddressRepository` (shared, see Profile) and `PaymentMethodRepository` (Payments feature).
- **Models:** `Address` (shared entity, canonical definition lives in `core/shared_entities` per `02_PROJECT_STRUCTURE.md` §11.1 exception rule), `ShippingMethod`, `CheckoutSession`.
- **Routes:** `/checkout/address`, `/checkout/shipping-payment`, `/checkout/review`, `/checkout/confirmation`.
- **Widgets:** `AddressCard`, `AddressForm`, `ShippingMethodTile`, `PaymentMethodTile`, `OrderSummaryPanel`, `StepperHeader` (checkout progress indicator).
- **Mock Data:** 2–3 mock shipping methods with distinct cost/ETA; reuses Address/PaymentMethod fixtures.
- **State Management:** `CheckoutBloc` (multi-step wizard state, one bloc spanning all four screens so back/forward preserves entries).
- **Navigation:** Cart → Address (push) → Shipping & Payment (push) → Review (push) → Confirmation (push, replaces stack so back doesn't re-submit) → Home or Order Detail.
- **Acceptance Criteria:** Cannot advance a step with invalid/missing required data; back navigation preserves previously entered data; placing an order is idempotent (double-tap does not create two orders); confirmation screen cannot be reached by direct deep link without a completed session.

---

## 9. Orders

**Package:** `packages/features/orders`

- **Purpose:** Post-purchase order tracking and lifecycle management for the customer.
- **Dependencies:** Checkout (order creation trigger), Products (line-item display).
- **Screens:** Order History, Order Detail (with tracking timeline), Cancel/Return flow.
- **Business Logic:** `GetOrders` (paginated), `GetOrderDetail`, `CancelOrder`, `RequestReturn`, `GetOrderTrackingEvents`.
- **Repositories:** `OrderRepository` → `MockOrderRepositoryImpl`.
- **Models:** `Order`, `OrderLineItem`, `OrderStatus` (enum: Placed, Processing, Shipped, Delivered, Cancelled, ReturnRequested, Returned), `OrderTrackingEvent`.
- **Routes:** `/orders`, `/orders/:orderId`, `/orders/:orderId/cancel`, `/orders/:orderId/return`.
- **Widgets:** `OrderListTile`, `OrderStatusBadge`, `OrderTrackingTimeline`, `CancelReturnDialog`.
- **Mock Data:** Demo user pre-seeded with orders in each status value for QA coverage.
- **State Management:** `OrderListBloc`, `OrderDetailBloc`.
- **Navigation:** Checkout confirmation → Order Detail (direct); shell nav/Profile → Order History → Order Detail (push) → Cancel/Return (modal).
- **Acceptance Criteria:** Cancel action only available for statuses where policy allows (Placed/Processing); status badge colors are token-driven (design system), not hardcoded; tracking timeline renders in chronological order and reflects the current status accurately.

---

## 10. Payments

**Package:** `packages/features/payments`

- **Purpose:** Manage saved payment methods and provide the gateway abstraction that a future real provider will implement.
- **Dependencies:** Authentication (methods are per-user).
- **Screens:** Saved Payment Methods, Add Payment Method.
- **Business Logic:** `GetPaymentMethods`, `AddPaymentMethod`, `RemovePaymentMethod`, `SetDefaultPaymentMethod`, `ProcessPayment` (delegates to `PaymentGateway`).
- **Repositories:** `PaymentMethodRepository` → `MockPaymentMethodRepositoryImpl`; `PaymentGateway` interface → `MockPaymentGateway` (simulates authorize/capture/decline).
- **Models:** `PaymentMethod` (type: card/wallet/COD; masked display data only), `PaymentResult`.
- **Routes:** `/payment-methods`, `/payment-methods/add`.
- **Widgets:** `PaymentMethodCard`, `AddCardForm` (mock, Luhn-validated but never transmits real card data), `PaymentBrandIcon`.
- **Mock Data:** Demo user pre-seeded with 1–2 masked mock payment methods.
- **State Management:** `PaymentMethodsCubit`.
- **Navigation:** Accessible from Profile/Settings and from Checkout's shipping-payment step (inline add flow via modal, not full navigation, to avoid losing checkout state).
- **Acceptance Criteria:** Card number/CVV are masked in all UI and never logged; at least one payment method must exist (or COD selected) to complete checkout; removing the default method requires selecting a new default first.

---

## 11. Notifications

**Package:** `packages/features/notifications`

- **Purpose:** Centralize order, marketing, and system notifications; structured as the seam for future FCM integration.
- **Dependencies:** Orders (status-change notifications), Marketing (promotional notifications).
- **Screens:** Notification Center, Notification Preferences.
- **Business Logic:** `GetNotifications`, `MarkAsRead`, `MarkAllAsRead`, `GetNotificationPreferences`, `UpdateNotificationPreferences`, `SimulateIncomingNotification` (dev/mock only).
- **Repositories:** `NotificationRepository` → `MockNotificationRepositoryImpl`.
- **Models:** `AppNotification` (category: Order, Promotion, System; read/unread), `NotificationPreferences`.
- **Routes:** `/notifications`, `/notifications/preferences`.
- **Widgets:** `NotificationTile`, `NotificationCategoryFilterChip`, `UnreadBadge` (shell-level).
- **Mock Data:** Demo user pre-seeded with a mixed read/unread set across all categories.
- **State Management:** `NotificationBloc`, `NotificationPreferencesCubit`.
- **Navigation:** Shell nav bell icon → Notification Center → tapping a notification deep-links to its related entity (e.g., Order Detail) → Preferences (push from Center or Settings).
- **Acceptance Criteria:** Unread count badge updates in real time within the app session; disabling a category in Preferences prevents new mock notifications of that category from being generated; tapping a notification always resolves to a valid destination or a graceful fallback if the referenced entity no longer exists.

---

## 12. Profile

**Package:** `packages/features/profile`

- **Purpose:** Account information and address book management for the logged-in customer.
- **Dependencies:** Authentication (`User` entity), Checkout (`Address` shared entity).
- **Screens:** Profile Overview, Edit Profile, Address Book, Add/Edit Address.
- **Business Logic:** `GetProfile`, `UpdateProfile`, `GetAddresses`, `AddAddress`, `UpdateAddress`, `DeleteAddress`, `SetDefaultAddress`.
- **Repositories:** `ProfileRepository` → `MockProfileRepositoryImpl`; `AddressRepository` (shared with Checkout) → `MockAddressRepositoryImpl`.
- **Models:** `Profile` (extends/wraps `User` with additional preference fields), `Address` (shared, see Checkout).
- **Routes:** `/profile`, `/profile/edit`, `/profile/addresses`, `/profile/addresses/add`, `/profile/addresses/:addressId/edit`.
- **Widgets:** `ProfileHeader`, `ProfileMenuTile`, `AddressCard` (reused from Checkout's design-system-level component), `AddressForm` (reused).
- **Mock Data:** Demo user profile with 1–2 saved addresses.
- **State Management:** `ProfileBloc`, `AddressBookCubit`.
- **Navigation:** Shell nav → Profile Overview → Edit Profile / Address Book (push) → Add/Edit Address (push/modal).
- **Acceptance Criteria:** Deleting an address in use as an order's shipping address is blocked or requires confirmation with clear messaging; profile edits validate email/phone formats via shared `core/utils/validators.dart`.

---

## 13. Settings

**Package:** `packages/features/settings`

- **Purpose:** App-level preference and security controls independent of commerce identity.
- **Dependencies:** Authentication (password change, session), Configuration (theme/locale hooks into `AppConfig`).
- **Screens:** Settings, Change Password, Security Settings.
- **Business Logic:** `GetAppSettings`, `UpdateThemeMode`, `UpdateLocale`, `ChangePassword`, `ToggleBiometricLogin` (placeholder contract).
- **Repositories:** `SettingsRepository` → `MockSettingsRepositoryImpl` (local persistence-backed).
- **Models:** `AppSettings` (themeMode, locale, biometricEnabled).
- **Routes:** `/settings`, `/settings/change-password`, `/settings/security`.
- **Widgets:** `SettingsSectionHeader`, `SettingsToggleTile`, `SettingsNavigationTile`, `LanguagePickerSheet`.
- **Mock Data:** Default settings per fresh install; persisted locally once changed.
- **State Management:** `SettingsCubit`.
- **Navigation:** Shell nav/Profile menu → Settings → sub-screens (push).
- **Acceptance Criteria:** Theme change applies instantly app-wide without restart; locale change is reflected in all currently-rendered strings sourced from `intl`; password change requires current password re-entry and enforces password policy via shared validators.

---

## 14. Support

**Package:** `packages/features/support`

- **Purpose:** Self-service help content and assisted support ticketing.
- **Dependencies:** Authentication (ticket ownership).
- **Screens:** Help Center / FAQ, Contact / Create Ticket, Ticket Status.
- **Business Logic:** `GetFaqItems`, `SearchFaq`, `CreateSupportTicket`, `GetMyTickets`, `GetTicketDetail`.
- **Repositories:** `SupportRepository` → `MockSupportRepositoryImpl`.
- **Models:** `FaqItem` (category, question, answer), `SupportTicket` (status: Open/InProgress/Resolved/Closed).
- **Routes:** `/support`, `/support/contact`, `/support/tickets`, `/support/tickets/:ticketId`.
- **Widgets:** `FaqAccordionTile`, `FaqCategoryTab`, `TicketForm`, `TicketStatusBadge`.
- **Mock Data:** ≥15 FAQ entries across ≥4 categories; demo user pre-seeded with 1 ticket in progress.
- **State Management:** `FaqCubit`, `SupportTicketBloc`.
- **Navigation:** Shell nav/Settings → Help Center → FAQ detail (expand in place) or Contact (push) → Ticket Status (push, and reachable again later from a "My Tickets" list).
- **Acceptance Criteria:** FAQ is searchable and filterable by category; ticket creation form validates required fields and shows confirmation with a trackable ticket ID.

---

## 15. Admin Access Control (RBAC)

**Package:** Extends `packages/features/authentication` domain (`AdminRole`, permission model) + `packages/core/lib/routing` (guard) + `apps/admin` shell. Not a standalone feature package — documented here because it is a hard prerequisite for every admin feature below.

- **Purpose:** Restrict admin app navigation and actions by role.
- **Dependencies:** Authentication.
- **Screens:** None new (extends Login for admin context; "Access Denied" state screen).
- **Business Logic:** `GetCurrentAdminRole`, `HasPermission(permission)`, role→permission mapping table (`SuperAdmin`, `CatalogManager`, `OrderManager`, `MarketingManager`, `SupportAgent` as the baseline role set).
- **Repositories:** Reuses `AuthRepository`; adds `RolePermissionMap` as a static/config-driven lookup (tenant-overridable — a tenant may rename/restrict roles).
- **Models:** `AdminRole` (enum), `Permission` (enum), `RolePermissionMap`.
- **Routes:** N/A (cross-cutting guard applied to all `/admin/**` routes); `/admin/access-denied`.
- **Widgets:** `AccessDeniedView`, `RoleBadge` (shown in admin shell header).
- **Mock Data:** One mock admin user per role in the seeded user set (from Authentication).
- **State Management:** Consumes `AuthBloc` state; exposes a `PermissionGuard` widget/utility for conditional rendering.
- **Navigation:** Unauthorized route access → redirect to `/admin/access-denied` or `/admin/dashboard` per policy documented in `09_ROUTING_PLAN.md`.
- **Acceptance Criteria:** A `SupportAgent` cannot reach `/admin/catalog/**` even via direct URL entry on Web; nav items for unauthorized sections are hidden, not just disabled.

---

## 16. Admin Dashboard & Analytics

**Package:** `packages/features/admin_dashboard`, `packages/features/analytics_reports`

- **Purpose:** Give admins at-a-glance store health and deeper reporting.
- **Dependencies:** Orders, Products, Admin Access Control.
- **Screens:** Admin Dashboard, Analytics Detail, Reports.
- **Business Logic:** `GetDashboardKpis` (sales, orders, AOV, conversion placeholder), `GetSalesTrend`, `GetTopProducts`, `GenerateReport`.
- **Repositories:** `AnalyticsRepository` → `MockAnalyticsRepositoryImpl` (derives figures from Orders/Products mock data for internal consistency).
- **Models:** `DashboardKpiSet`, `SalesTrendPoint`, `ReportDefinition`, `ReportResult`.
- **Routes:** `/admin/dashboard`, `/admin/analytics`, `/admin/reports`.
- **Widgets:** `KpiCard`, `LineChartCard`, `BarChartCard`, `TopProductsTable`, `ReportExportButton` (mock export).
- **Mock Data:** Analytics fixtures generated deterministically from seeded Orders/Products so numbers stay internally consistent.
- **State Management:** `AdminDashboardBloc`, `ReportsCubit`.
- **Navigation:** Admin shell root → Dashboard; side nav → Analytics / Reports.
- **Acceptance Criteria:** Charts render correctly with zero, one, and many data points; report generation shows a loading state and a mock "exported" confirmation.

---

## 17. Admin Catalog Management

**Package:** `packages/features/admin_catalog`

- **Purpose:** Full CRUD over the product catalog and category tree consumed by the storefront.
- **Dependencies:** Products (domain reuse), Categories (domain reuse), Admin Access Control.
- **Screens:** Product Management List, Product Create/Edit Form, Category Management List, Category Create/Edit Form.
- **Business Logic:** `CreateProduct`, `UpdateProduct`, `DeleteProduct`, `BulkUpdateProductStatus`, `CreateCategory`, `UpdateCategory`, `DeleteCategory`, `ReorderCategories`.
- **Repositories:** Operates through the existing `ProductRepository`/`CategoryRepository` interfaces (no duplicate repository) — admin-only mutation use cases live in this package's domain layer and call the same repository.
- **Models:** Reuses `Product`, `ProductVariant`, `Category` from their owning features (imported via barrel export).
- **Routes:** `/admin/catalog/products`, `/admin/catalog/products/new`, `/admin/catalog/products/:productId/edit`, `/admin/catalog/categories`, `/admin/catalog/categories/new`, `/admin/catalog/categories/:categoryId/edit`.
- **Widgets:** `AdminDataTable` (design-system table), `ProductForm`, `CategoryForm`, `BulkActionToolbar`, `ImageUploaderMock`.
- **Mock Data:** Mutates the same in-memory/shared mock store used by the storefront `products`/`categories` features so admin edits are visible in the customer app within the same running session.
- **State Management:** `ProductManagementBloc`, `CategoryManagementBloc`.
- **Navigation:** Admin shell side nav → Catalog → Products/Categories list → Create/Edit form (push or side panel).
- **Acceptance Criteria:** Creating a product with required fields missing shows inline validation and does not submit; deleting a category with child categories or assigned products is blocked with an explanatory dialog; changes are immediately reflected in storefront mock data within the same app session.

---

## 18. Admin Inventory

**Package:** `packages/features/admin_inventory`

- **Purpose:** Track and adjust stock levels per product/variant; surface low-stock alerts.
- **Dependencies:** Products, Admin Catalog, Admin Access Control.
- **Screens:** Inventory Overview, Stock Adjustment, Low Stock Alerts.
- **Business Logic:** `GetStockLevels`, `AdjustStock`, `GetLowStockItems`, `SetLowStockThreshold`.
- **Repositories:** `InventoryRepository` → `MockInventoryRepositoryImpl` (wraps/extends `ProductRepository` stock fields).
- **Models:** `StockLevel` (productId, variantId, quantity, threshold), `StockAdjustment` (audit record: reason, delta, timestamp, actor).
- **Routes:** `/admin/inventory`, `/admin/inventory/:productId/adjust`, `/admin/inventory/alerts`.
- **Widgets:** `StockLevelTable`, `StockAdjustmentDialog`, `LowStockBadge`.
- **Mock Data:** A subset of seeded products deliberately set below threshold to exercise the alert path.
- **State Management:** `InventoryBloc`.
- **Navigation:** Admin shell side nav → Inventory → Adjust (modal) / Alerts (push).
- **Acceptance Criteria:** Stock adjustments are audit-logged (visible in an adjustment history view); a product crossing below threshold appears in Low Stock Alerts within the same session without manual refresh.

---

## 19. Admin Order Management

**Package:** `packages/features/admin_orders`

- **Purpose:** Operational management of customer orders.
- **Dependencies:** Orders (domain reuse), Admin Access Control.
- **Screens:** Order Management List, Order Management Detail.
- **Business Logic:** `GetAllOrders` (admin-scoped, all customers, filterable/sortable), `UpdateOrderStatus`, `IssueRefund` (mock), `AddOrderNote`.
- **Repositories:** Operates through `OrderRepository` (shared interface with customer Orders feature).
- **Models:** Reuses `Order`, `OrderStatus`, `OrderLineItem`; adds `OrderNote` (internal, admin-only).
- **Routes:** `/admin/orders`, `/admin/orders/:orderId`.
- **Widgets:** `AdminOrderTable`, `OrderStatusDropdown` (enforces legal transitions), `RefundDialog`, `OrderNoteThread`.
- **Mock Data:** Reuses/extends customer Orders fixtures across multiple mock customers.
- **State Management:** `AdminOrderListBloc`, `AdminOrderDetailBloc`.
- **Navigation:** Admin shell side nav → Orders → Detail (push).
- **Acceptance Criteria:** Status transitions follow the defined state machine (illegal transitions unavailable in the dropdown, not just rejected after the fact); status change is reflected in the customer app's Order History/Detail within the same session.

---

## 20. Admin Customer Management

**Package:** `packages/features/admin_customers`

- **Purpose:** View and manage customer accounts and their commerce history.
- **Dependencies:** Authentication (`User`), Orders, Admin Access Control.
- **Screens:** Customer List, Customer Detail (profile + order history + notes).
- **Business Logic:** `GetCustomers` (paginated, searchable), `GetCustomerDetail`, `SuspendCustomer`, `ReactivateCustomer`, `AddCustomerNote`.
- **Repositories:** `AdminCustomerRepository` → `MockAdminCustomerRepositoryImpl` (composes `AuthRepository`/user store + `OrderRepository`).
- **Models:** `CustomerSummary` (list view model), `CustomerDetail` (aggregate view model), `CustomerNote`.
- **Routes:** `/admin/customers`, `/admin/customers/:customerId`.
- **Widgets:** `CustomerTable`, `CustomerProfilePanel`, `CustomerOrderHistoryList`, `CustomerNoteThread`, `SuspendConfirmationDialog`.
- **Mock Data:** ≥10 mock customers with varied order histories and account states.
- **State Management:** `CustomerListBloc`, `CustomerDetailBloc`.
- **Navigation:** Admin shell side nav → Customers → Detail (push) → linked Order Detail (push, reuses Admin Order Management screen).
- **Acceptance Criteria:** Suspending a customer immediately blocks that mock user's login in the customer app within the same session; search filters by name/email/phone.

---

## 21. Marketing

**Package:** `packages/features/marketing`

- **Purpose:** Promotional tooling: coupons, promotions, storefront banners.
- **Dependencies:** Cart (promo code validation contract), Dashboard (banner consumption), Admin Access Control.
- **Screens:** Promotions List, Promotion Create/Edit, Banner Management.
- **Business Logic:** `CreateCoupon`, `UpdateCoupon`, `DeactivateCoupon`, `ValidateCoupon` (consumed by Cart's `ApplyPromoCode`), `CreateBanner`, `UpdateBanner`, `ReorderBanners`.
- **Repositories:** `PromotionRepository` → `MockPromotionRepositoryImpl`; `BannerRepository` → `MockBannerRepositoryImpl`.
- **Models:** `Coupon` (code, discountType, value, expiry, minSpend, usageLimit), `Banner` (image, target route, active window, sortOrder).
- **Routes:** `/admin/marketing/promotions`, `/admin/marketing/promotions/new`, `/admin/marketing/promotions/:id/edit`, `/admin/marketing/banners`.
- **Widgets:** `PromotionTable`, `PromotionForm`, `BannerManagerList`, `BannerForm`, `BannerPreview`.
- **Mock Data:** 3–5 seeded coupons (mix of valid/expired/usage-exhausted) and 3 seeded banners.
- **State Management:** `PromotionManagementBloc`, `BannerManagementCubit`.
- **Navigation:** Admin shell side nav → Marketing → Promotions/Banners (tabs or sub-nav).
- **Acceptance Criteria:** A coupon created here is immediately usable in the customer Cart's promo code field within the same session; a banner created here appears on the customer Home within the same session; expired/exhausted coupons are visibly flagged in the admin list.

---

## 22. White-Label / Tenant Management

**Package:** `packages/features/tenant_management`

- **Purpose:** Administer the branding/copy/feature-flag configuration that makes the platform white-label — the platform's core differentiator.
- **Dependencies:** Configuration (`TenantConfig`, `FeatureFlags` from `core`), Admin Access Control (SuperAdmin-only by default).
- **Screens:** Tenant Profile, Branding Editor (logo/colors/typography preview), Feature Flag Manager, Tenant Switcher (dev/demo aid).
- **Business Logic:** `GetTenantConfig`, `UpdateTenantBranding`, `UpdateTenantCopy`, `ToggleFeatureFlag`, `CreateTenant` (demo/dev tooling), `SwitchActiveTenant` (demo/dev tooling).
- **Repositories:** `TenantConfigRepository` → `MockTenantConfigRepositoryImpl` (reads/writes the `config/tenants/*.json` equivalent in-memory representation).
- **Models:** `TenantConfig`, `BrandingTokens` (colors, logo URL, font family reference), `CopyOverrides` (key→string map for tenant-specific text), `FeatureFlagSet`.
- **Routes:** `/admin/tenant/profile`, `/admin/tenant/branding`, `/admin/tenant/feature-flags`, `/admin/tenant/switch` (dev-only, hidden in production builds).
- **Widgets:** `BrandingColorPicker`, `LogoUploaderMock`, `LivePreviewPane` (renders a miniature storefront preview reacting live to edits), `FeatureFlagToggleRow`.
- **Mock Data:** `default_tenant` plus one fully distinct demo tenant (different name, palette, logo, and at least one disabled feature) used to prove the white-label claim.
- **State Management:** `TenantConfigBloc`.
- **Navigation:** Admin shell side nav (SuperAdmin only) → Tenant → Profile/Branding/Feature Flags (tabs).
- **Acceptance Criteria:** Editing branding updates the live preview pane without app restart; switching the active demo tenant restyles both the admin app itself and (on next launch or hot-reload of config) the storefront app with zero code changes; disabling a feature flag hides its entire navigation entry and blocks its routes in both apps.

---

## 23. Developer Panel (Cross-Cutting Utility)

**Package:** Lives alongside `packages/core` config utilities and a thin presentation layer inside each app (`apps/*/lib` dev tools), gated fully out of production builds via `AppConfig.isDeveloperModeAvailable`.

- **Purpose:** Accelerate QA and demos: reset mock data, switch environment/tenant, inspect feature flags, simulate notifications.
- **Dependencies:** Configuration, Mock Data Infrastructure, Notifications (for simulate action), Tenant Management (for tenant switch action).
- **Screens:** Developer Panel (single screen, tabbed sections).
- **Business Logic:** `ResetMockData`, `SwitchEnvironment` (dev/staging only), `SwitchTenant`, `SimulateNotification`, `ViewFeatureFlagState`.
- **Repositories:** No new repository; orchestrates existing mock repositories' reset hooks.
- **Models:** None new (utility surface over existing models).
- **Routes:** `/dev-panel` (registered only when `AppConfig.isDeveloperModeAvailable == true`; absent entirely from production route table).
- **Widgets:** `DevPanelSection`, `MockDataResetButton`, `EnvironmentSwitcherDropdown`.
- **Mock Data:** N/A (acts on other features' mock data).
- **State Management:** `DevPanelCubit`.
- **Navigation:** Reached via a hidden gesture/shake or an explicit menu item visible only in non-production flavors.
- **Acceptance Criteria:** Route and menu entry are completely absent from production release builds (verified by a build-time check, not just a runtime `if`); resetting mock data returns the app to its seeded baseline without restart.

---

## Dependency Graph Summary (Textual)

```
core, design_system
   └── authentication
         ├── dashboard ── (reads) ── marketing (banners), products, categories
         ├── products ── categories ── search
         ├── wishlist (needs products, auth)
         ├── cart (needs products, marketing[promo validation])
         │      └── checkout (needs cart, payments[minimal], profile[address], orders[creation])
         │             └── orders ── notifications (order events)
         ├── payments (needs auth)
         ├── profile (needs auth, checkout[address entity])
         ├── settings (needs auth, core config)
         ├── support (needs auth)
         └── admin_access_control (extends authentication)
                ├── admin_dashboard / analytics_reports (needs orders, products)
                ├── admin_catalog (needs products, categories)
                │      └── admin_inventory (needs admin_catalog, products)
                ├── admin_orders (needs orders)
                ├── admin_customers (needs authentication, orders)
                ├── marketing[admin screens] (needs cart[promo contract], dashboard[banner contract])
                └── tenant_management (needs core config)
                       └── developer_panel (needs config, mock infra, notifications, tenant_management)
```

This graph is the authoritative dependency order; `03_DEVELOPMENT_PHASES.md` phases 7–26 are a linearization of this graph with the one documented exception noted at Phase 14/15.
