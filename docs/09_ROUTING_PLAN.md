# 09 — Routing Plan

**Status:** Planning document. Complete routing strategy for both apps, using `go_router`. Route paths defined here are authoritative; any change must update this document in the same change (per `06_DEVELOPMENT_RULES.md` Rule 40).

---

## 1. Routing Architecture Overview

- Each app (`apps/storefront`, `apps/admin`) has exactly **one** `GoRouter` instance, composed in `app_router.dart` from each consumed feature's `<feature>_routes.dart` route list (see `02_PROJECT_STRUCTURE.md` §6).
- Both routers use `ShellRoute`/`StatefulShellRoute` for persistent chrome (bottom nav for storefront, side nav for admin) so navigating between top-level branches preserves each branch's own navigation stack.
- Guards are implemented via `GoRouter`'s `redirect` callback, delegating to shared logic in `packages/core/lib/routing/route_guard.dart` — never per-screen `initState` checks (Rule 41).
- Every route has a **named constant** (e.g., `ProductDetailRoute.name`) defined in its owning feature, and is navigated to via `context.goNamed(...)`/`context.pushNamed(...)`, never raw string paths at call sites.
- Deep links (mobile universal/app links, Web direct URL entry) resolve through the exact same route table and guard logic as in-app navigation — there is no parallel "deep link only" code path.

## 2. Storefront App (`apps/storefront`) — Route Table

### 2.1 Public Routes (no authentication required, subject to `allowGuestBrowsing` flag for catalog browsing)

| Path | Route Name | Screen | Notes |
|---|---|---|---|
| `/splash` | `SplashRoute` | Splash | Initial route, redirects immediately |
| `/onboarding` | `OnboardingRoute` | Onboarding | First-run only |
| `/login` | `LoginRoute` | Login | Accepts `?redirect=<path>` query param |
| `/register` | `RegisterRoute` | Register | |
| `/forgot-password` | `ForgotPasswordRoute` | Forgot Password | |
| `/verify-otp` | `VerifyOtpRoute` | OTP Verification | Accepts `?context=register\|reset` |
| `/home` | `HomeRoute` | Home | Public if `allowGuestBrowsing=true`, else redirects to Login |
| `/products` | `ProductListRoute` | Product Listing | Public if flag allows |
| `/products/:productId` | `ProductDetailRoute` | Product Detail | Public if flag allows |
| `/categories` | `CategoryBrowseRoute` | Category Browse | Public if flag allows |
| `/categories/:categoryId` | `CategoryDetailRoute` | Category Detail | Public if flag allows |
| `/search` | `SearchRoute` | Search (entry) | Public if flag allows |
| `/search/results` | `SearchResultsRoute` | Search Results | Accepts `?q=`, `?filters=`, `?sort=` |
| `/support` | `HelpCenterRoute` | Help Center / FAQ | Always public |

### 2.2 Authenticated Routes (require valid customer session)

| Path | Route Name | Screen |
|---|---|---|
| `/wishlist` | `WishlistRoute` | Wishlist |
| `/cart` | `CartRoute` | Cart *(public if guest-cart flag enabled — see §6)* |
| `/checkout/address` | `CheckoutAddressRoute` | Address Selection/Entry |
| `/checkout/shipping-payment` | `CheckoutShippingPaymentRoute` | Shipping & Payment Method |
| `/checkout/review` | `CheckoutReviewRoute` | Order Review |
| `/checkout/confirmation/:orderId` | `CheckoutConfirmationRoute` | Order Confirmation |
| `/orders` | `OrderHistoryRoute` | Order History |
| `/orders/:orderId` | `OrderDetailRoute` | Order Detail |
| `/orders/:orderId/cancel` | `OrderCancelRoute` | Cancel Flow (modal route) |
| `/orders/:orderId/return` | `OrderReturnRoute` | Return Flow (modal route) |
| `/payment-methods` | `PaymentMethodsRoute` | Saved Payment Methods |
| `/payment-methods/add` | `AddPaymentMethodRoute` | Add Payment Method |
| `/notifications` | `NotificationCenterRoute` | Notification Center |
| `/notifications/preferences` | `NotificationPreferencesRoute` | Notification Preferences |
| `/profile` | `ProfileRoute` | Profile Overview |
| `/profile/edit` | `EditProfileRoute` | Edit Profile |
| `/profile/addresses` | `AddressBookRoute` | Address Book |
| `/profile/addresses/add` | `AddAddressRoute` | Add Address |
| `/profile/addresses/:addressId/edit` | `EditAddressRoute` | Edit Address |
| `/settings` | `SettingsRoute` | Settings |
| `/settings/change-password` | `ChangePasswordRoute` | Change Password |
| `/settings/security` | `SecuritySettingsRoute` | Security Settings |
| `/support/contact` | `SupportContactRoute` | Contact / Create Ticket |
| `/support/tickets` | `SupportTicketsRoute` | Ticket list |
| `/support/tickets/:ticketId` | `SupportTicketDetailRoute` | Ticket Status |

### 2.3 Dev-Only Routes (registered only when `AppConfig.isDeveloperModeAvailable == true`)

| Path | Route Name | Screen |
|---|---|---|
| `/dev-panel` | `DevPanelRoute` | Developer Panel |

### 2.4 Shell Structure (Storefront)

```
StatefulShellRoute (AppBottomNavBar)
 ├── Branch: Home            → /home
 ├── Branch: Categories      → /categories, /categories/:categoryId
 ├── Branch: Search          → /search, /search/results
 ├── Branch: Wishlist        → /wishlist
 └── Branch: Profile         → /profile, /profile/**, /settings/**, /support/**
Outside shell (full-screen, pushed over shell):
 /products/:productId, /cart, /checkout/**, /orders/**, /payment-methods/**,
 /notifications/**
Pre-shell (no chrome):
 /splash, /onboarding, /login, /register, /forgot-password, /verify-otp
```

`/products` itself is reachable both as a shell-less pushed screen (from Category Detail context) and could alternatively be a shell branch if the pilot tenant prefers a persistent "Shop" tab — **decision point for kickoff**: default assumption is a "Shop" tab is added as a 6th branch pointing at `/products`; confirmed per-tenant via `TenantConfig.enabledNavItems`.

---

## 3. Admin App (`apps/admin`) — Route Table

### 3.1 Public Routes

| Path | Route Name | Screen |
|---|---|---|
| `/admin/login` | `AdminLoginRoute` | Login (admin context) |
| `/admin/forgot-password` | `AdminForgotPasswordRoute` | Forgot Password |
| `/admin/verify-otp` | `AdminVerifyOtpRoute` | OTP Verification |

### 3.2 Authenticated + Role-Guarded Routes

| Path | Route Name | Required Permission | Screen |
|---|---|---|---|
| `/admin/dashboard` | `AdminDashboardRoute` | any admin role | Admin Dashboard |
| `/admin/analytics` | `AdminAnalyticsRoute` | any admin role | Analytics Detail |
| `/admin/reports` | `AdminReportsRoute` | any admin role | Reports |
| `/admin/catalog/products` | `AdminProductListRoute` | CatalogManager | Product Management List |
| `/admin/catalog/products/new` | `AdminProductCreateRoute` | CatalogManager | Product Create |
| `/admin/catalog/products/:productId/edit` | `AdminProductEditRoute` | CatalogManager | Product Edit |
| `/admin/catalog/categories` | `AdminCategoryListRoute` | CatalogManager | Category Management List |
| `/admin/catalog/categories/new` | `AdminCategoryCreateRoute` | CatalogManager | Category Create |
| `/admin/catalog/categories/:categoryId/edit` | `AdminCategoryEditRoute` | CatalogManager | Category Edit |
| `/admin/inventory` | `AdminInventoryRoute` | CatalogManager | Inventory Overview |
| `/admin/inventory/:productId/adjust` | `AdminStockAdjustRoute` | CatalogManager | Stock Adjustment |
| `/admin/inventory/alerts` | `AdminLowStockAlertsRoute` | CatalogManager | Low Stock Alerts |
| `/admin/orders` | `AdminOrderListRoute` | OrderManager | Order Management List |
| `/admin/orders/:orderId` | `AdminOrderDetailRoute` | OrderManager | Order Management Detail |
| `/admin/customers` | `AdminCustomerListRoute` | OrderManager | Customer List |
| `/admin/customers/:customerId` | `AdminCustomerDetailRoute` | OrderManager | Customer Detail |
| `/admin/marketing/promotions` | `AdminPromotionListRoute` | MarketingManager | Promotions List |
| `/admin/marketing/promotions/new` | `AdminPromotionCreateRoute` | MarketingManager | Promotion Create |
| `/admin/marketing/promotions/:id/edit` | `AdminPromotionEditRoute` | MarketingManager | Promotion Edit |
| `/admin/marketing/banners` | `AdminBannerListRoute` | MarketingManager | Banner Management |
| `/admin/tenant/profile` | `AdminTenantProfileRoute` | SuperAdmin | Tenant Profile |
| `/admin/tenant/branding` | `AdminTenantBrandingRoute` | SuperAdmin | Branding Editor |
| `/admin/tenant/feature-flags` | `AdminFeatureFlagsRoute` | SuperAdmin | Feature Flag Manager |
| `/admin/tenant/switch` | `AdminTenantSwitchRoute` | SuperAdmin + DEV only | Tenant Switcher |
| `/admin/settings` | `AdminSettingsRoute` | any admin role | Settings |
| `/admin/settings/change-password` | `AdminChangePasswordRoute` | any admin role | Change Password |
| `/admin/access-denied` | `AdminAccessDeniedRoute` | any admin role (landing, not gated) | Access Denied |
| `/admin/dev-panel` | `AdminDevPanelRoute` | DEV only | Developer Panel |

### 3.3 Shell Structure (Admin)

```
StatefulShellRoute (AppSideNav, role-filtered items)
 ├── Branch: Dashboard    → /admin/dashboard, /admin/analytics, /admin/reports
 ├── Branch: Catalog      → /admin/catalog/**, /admin/inventory/**
 ├── Branch: Orders       → /admin/orders/**
 ├── Branch: Customers    → /admin/customers/**
 ├── Branch: Marketing    → /admin/marketing/**
 ├── Branch: Tenant       → /admin/tenant/** (hidden entirely for non-SuperAdmin)
 └── Branch: Settings     → /admin/settings/**
Pre-shell (no chrome):
 /admin/login, /admin/forgot-password, /admin/verify-otp
```

---

## 4. Redirect Rules (Guard Logic, `core/routing/route_guard.dart`)

Evaluated in this order on every navigation event, for both apps (parameterized by which route table is active):

1. **Maintenance check:** If `AppConfig.maintenanceMode(app)` is true → redirect to `/maintenance` (all routes except the maintenance screen itself and, for the admin app, an override path for SuperAdmin to disable maintenance mode).
2. **Auth check:** If the target route is in the Authenticated set and no valid session exists → redirect to `/login` (or `/admin/login`) with `?redirect=<originalPath>` appended.
3. **Role/permission check (admin only):** If the target route declares a `requiredPermission` and the current admin's role does not satisfy it → redirect to `/admin/access-denied`.
4. **Post-login redirect:** After successful login, if a `?redirect=` param is present and still valid for the now-known role, navigate there; otherwise navigate to the role-appropriate default landing (`/home` or `/admin/dashboard`).
5. **Feature-flag check:** If the target route's owning feature is disabled via `FeatureFlags` for the active tenant → treat as unmatched route (fall through to 404), **not** access-denied (a disabled feature should look absent, not forbidden — see `06_DEVELOPMENT_RULES.md` Rule 39).
6. **Already-authenticated-at-auth-route check:** If a valid session exists and the target route is Login/Register/Forgot Password/OTP → redirect to the default landing (prevents re-showing auth screens to a logged-in user via back button or stale bookmark).

## 5. Deep Links

- **Mobile:** Universal Links (iOS) / App Links (Android) configured for the tenant's primary domain, mapping directly to the storefront path table above (e.g., `https://shop.tenant.com/products/123` → `/products/123`). Admin deep links are not exposed as universal links (admin access is expected via direct app/browser use, not marketing links).
- **Web:** All paths above are directly browsable/bookmarkable URLs by construction (`go_router`'s URL strategy set to path-based, no `#` fragment, via `usePathUrlStrategy()`).
- **Notification deep links:** Each `AppNotification` carries a `deepLinkRoute` + typed params, resolved through the same named-route mechanism — never a raw string manipulated ad hoc in the notification tap handler.
- **Resolution failure policy:** A deep link to a since-deleted entity (e.g., a product that was removed) does not throw — the target screen's data-loading layer returns a domain "not found" failure, and the screen renders its standard Error/Empty state with a link back to a sensible parent (Product Listing, Order History, etc.), per screen-specific "Edge Cases" in `07_SCREEN_CATALOG.md`.

## 6. Guest / Public Access Configuration

- `TenantConfig.allowGuestBrowsing` (bool): when true, Home/Products/Categories/Search are reachable without a session; actions requiring identity (wishlist, review, checkout) still individually redirect to Login with a return-to path.
- `TenantConfig.allowGuestCart` (bool): when true, `/cart` and adding items to cart work pre-authentication, with the cart persisted locally and merged into the user's server-side cart contract upon login (merge strategy documented for the future backend-integration phase in `10_DATA_FLOW.md`; Phase 1 mock behavior: guest cart persists in local storage keyed by device, migrated to the user's mock cart record on login).

## 7. 404 Handling

- Both routers set `errorBuilder`/`errorPageBuilder` to the shared `AppNotFoundScreen` (design-system-hosted or a tiny dedicated feature — implementation detail, not user-facing routing difference).
- The 404 screen's primary CTA routes to `/home` (storefront) or `/admin/dashboard` (admin), never back to the broken path.
- A 404 is distinct from a domain-level "not found" (e.g., deleted product) — the former is an unmatched route; the latter is a matched route whose data failed to resolve, handled in-screen per §5's resolution failure policy. This distinction matters for analytics/error-tracking categorization once wired to a real backend.

## 8. Maintenance Mode

- `AppConfig` exposes independent `storefrontMaintenanceMode` and `adminMaintenanceMode` flags (per §3.3, an admin must be able to fix a storefront issue while the storefront is down).
- When active, the guard (Rule 1 in §4) redirects **every** route except the maintenance screen itself to that screen; the maintenance screen polls (or is manually refreshed by the user) to detect when the flag clears.
- Maintenance mode is tenant-and-environment scoped (a single tenant can be put into maintenance without affecting others once multi-tenant runtime switching exists beyond the dev Tenant Switcher).

## 9. Future Expansion

- **Localized routes:** If a tenant requires locale-prefixed URLs (`/en/products/123`, `/fr/products/123`) for Web SEO, this is additive — a locale segment is prepended to the existing path table via a wrapping `ShellRoute`, with no changes to individual feature route definitions (they stay locale-agnostic, reading the active locale from `AppConfig`/`intl` rather than the URL, until this expansion is scoped).
- **New top-level shell branches:** Adding a new customer-facing top-level feature (e.g., a future "Loyalty Program") is added as a new `StatefulShellRoute` branch and a new `<feature>_routes.dart`, without modifying any existing feature's route file.
- **Multi-storefront-per-tenant:** Not in current scope; if required later, the router would need a tenant-slug path segment (`/t/:tenantSlug/...`) — flagged here as an architecturally anticipated but undesigned extension point, to be scoped via an ADR before implementation.
- **Server-driven routing/CMS pages:** A tenant-authored static page system (e.g., "About Us", "Terms") is anticipated as a generic `/:slug` catch-all route resolved against a future `CmsPageRepository`, lower priority than the 404 route in matching order.
