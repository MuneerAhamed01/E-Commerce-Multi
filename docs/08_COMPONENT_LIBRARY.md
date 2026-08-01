# 08 — Component Library

**Status:** Planning document. Every reusable component the platform needs, specified before any is built. All components live in `packages/design_system/lib/components/` (see `02_PROJECT_STRUCTURE.md` §5) and are prefixed `App*` to disambiguate from Flutter/Material widgets (see naming convention in `02_PROJECT_STRUCTURE.md` §10).

**Golden rule (restated from `06_DEVELOPMENT_RULES.md` Rule 9 & 10):** If a screen needs a visual element that resembles something below, it reuses this component with new data/props — it never redefines a lookalike locally. Every component consumes design tokens (`AppColors`, `AppTypography`, `AppSpacing`, `AppRadii`) exclusively — no literal values.

---

## 1. Buttons

| Component | Purpose | Variants | Key Props | States | Used In |
|---|---|---|---|---|---|
| `AppButton` | Primary tappable action | `primary`, `secondary`, `outline`, `text`, `destructive` | `label`, `onPressed`, `icon?`, `isLoading`, `isFullWidth`, `size` (sm/md/lg) | default, hover(web), pressed, disabled, loading (inline spinner replaces label) | Everywhere (forms, CTAs, dialogs) |
| `AppIconButton` | Icon-only tappable action | `standard`, `filled`, `outline` | `icon`, `onPressed`, `tooltip`, `size` | default, disabled | App bars, table row actions, cart quantity controls |
| `AppTextLinkButton` | Low-emphasis inline action | — | `label`, `onPressed` | default, disabled | "Forgot password?", "View all", "Clear filters" |
| `AppFloatingActionButton` | Primary screen-level action (mobile) | `extended`, `mini` | `label?`, `icon`, `onPressed` | default, disabled | Admin "Create Product/Category/Coupon" on mobile breakpoint |

## 2. Cards

| Component | Purpose | Variants | Key Props | States | Used In |
|---|---|---|---|---|---|
| `AppCard` | Generic elevated/outlined container | `elevated`, `outlined`, `flat` | `child`, `onTap?`, `padding` | default, pressed (if tappable) | Base for most cards below |
| `ProductCard` | Product summary tile in a grid | `grid`, `list` | `product`, `onTap`, `onWishlistToggle`, `isWishlisted` | loading (shimmer), loaded, out-of-stock overlay | Product Listing, Search Results, Home, Wishlist |
| `OrderCard` / `OrderListTile` | Order summary row | — | `order`, `onTap` | default | Order History, Admin Order Management |
| `AddressCard` | Address summary with select/edit/delete actions | `selectable`, `readonly` | `address`, `isDefault`, `onEdit`, `onDelete`, `onSelect` | default, selected | Address Book, Checkout |
| `PaymentMethodCard` | Masked payment method summary | — | `method`, `isDefault`, `onRemove`, `onSetDefault` | default | Saved Payment Methods, Checkout |
| `KpiCard` | Single metric display for dashboards | `positive-trend`, `negative-trend`, `neutral` | `label`, `value`, `deltaPercent?`, `icon?` | loading (shimmer), loaded | Admin Dashboard |
| `PromotionCard` | Coupon/promotion summary | `active`, `expired`, `exhausted` | `promotion` | default | Promotions List (mobile fallback for `AdminDataTable`) |

## 3. Dialogs

| Component | Purpose | Variants | Key Props | States | Used In |
|---|---|---|---|---|---|
| `AppAlertDialog` | Simple confirm/cancel decision | `standard`, `destructive` | `title`, `message`, `confirmLabel`, `cancelLabel`, `onConfirm` | default | Delete/cancel/suspend confirmations |
| `CancelReturnDialog` | Order cancel/return reason capture | `cancel`, `return` | `order`, `reasons`, `onSubmit` | default, submitting | Orders |
| `RefundDialog` | Admin refund issuance confirmation | — | `order`, `onSubmit` | default, submitting | Admin Order Management |
| `StockAdjustmentDialog` | Manual stock change with reason | — | `stockLevel`, `onSubmit` | default, submitting, validation-error | Admin Inventory |
| `SuspendConfirmationDialog` | Customer suspend/reactivate confirmation | `suspend`, `reactivate` | `customer`, `onConfirm` | default | Admin Customer Management |

## 4. Bottom Sheets

| Component | Purpose | Variants | Key Props | States | Used In |
|---|---|---|---|---|---|
| `FilterBottomSheet` | Multi-facet filter selection | — | `availableFilters`, `activeFilters`, `onApply`, `onClear` | default, applying | Product Listing, Search Results |
| `SortBottomSheet` | Sort option selection | — | `options`, `selected`, `onSelect` | default | Product Listing, Search Results |
| `LanguagePickerSheet` | Locale selection | — | `locales`, `selected`, `onSelect` | default | Settings |
| `AppActionSheet` | Generic list of contextual actions | — | `actions` (label+icon+callback list) | default | Order line item long-press, Admin table row "more" menu |

## 5. Text Fields / Inputs

| Component | Purpose | Variants | Key Props | States | Used In |
|---|---|---|---|---|---|
| `AppTextField` | Base text input | `outlined`, `filled` | `label`, `hint`, `controller`, `validator`, `obscureText`, `keyboardType`, `errorText` | default, focused, error, disabled | Forms across the app |
| `AuthTextField` | `AppTextField` preset for auth forms | — | same as base + `autofillHints` | same | Login/Register/Profile |
| `PasswordStrengthIndicator` | Visual password strength meter | — | `password` | weak/fair/strong | Register, Change Password |
| `OtpInputRow` | Segmented OTP entry | — | `length`, `onCompleted` | default, error (shake) | OTP Verification |
| `SearchBar` | Debounced query input with clear affordance | `standalone`, `shell-embedded` | `onChanged`, `onSubmit`, `hintText` | default, focused, has-text | Search, shell app bar |
| `QuantityStepper` | Increment/decrement quantity control | — | `value`, `min`, `max`, `onChanged` | default, at-min, at-max, disabled | Cart, Admin Stock Adjustment |
| `PromoCodeField` | Code entry with apply action and inline result | — | `onApply`, `appliedCode?`, `errorText?` | default, applied (success), error | Cart |
| `AppDropdown<T>` | Generic labeled dropdown/select | — | `items`, `value`, `onChanged`, `label` | default, disabled | Admin forms, Sort selection |

## 6. Search & Filter Chips

| Component | Purpose | Variants | Key Props | States | Used In |
|---|---|---|---|---|---|
| `RecentSearchChip` | Tappable recent/trending search term | — | `label`, `onTap`, `onRemove?` | default | Search entry |
| `SearchSuggestionTile` | Row-style live suggestion | `product`, `category`, `query-completion` | `suggestion`, `onTap` | default | Search entry |
| `FilterChip` (`AppFilterChip`) | Toggleable filter facet | `selected`, `unselected` | `label`, `selected`, `onTap` | default, selected | Filter sheet |
| `ActiveFilterChipRow` | Row of currently-applied filters with individual remove | — | `filters`, `onRemove`, `onClearAll` | default | Product Listing, Search Results |

## 7. Product / Commerce Specific

| Component | Purpose | Variants | Key Props | States | Used In |
|---|---|---|---|---|---|
| `ProductGrid` | Responsive paginated product grid | — | `items`, `onLoadMore`, `isLoadingMore` | loading, loaded, empty, error | Product Listing, Search Results, Wishlist, Category Detail |
| `ProductGallery` | Swipeable image/zoom gallery | — | `images`, `initialIndex` | default | Product Detail |
| `VariantSelector` | Attribute-based variant picker (size/color/etc.) | `chip`, `swatch`, `dropdown` | `variants`, `selected`, `onSelect` | default, out-of-stock (visually distinct, still tappable) | Product Detail |
| `RatingSummary` | Aggregate star rating + count | — | `average`, `count` | default | Product Detail, Product Card |
| `ReviewList` | Paginated list of reviews | — | `reviews`, `onLoadMore` | loading, loaded, empty | Product Detail |
| `ReviewSubmissionForm` | Star + text review entry | — | `onSubmit` | default, submitting, submitted | Product Detail |
| `WishlistToggleButton` | Heart-icon wishlist toggle, globally state-synced | — | `productId`, `variantId?` | active, inactive, loading (debounced tap) | Product Card, Product Detail |
| `CartLineItem` | Single cart row with quantity/remove | — | `item`, `onQuantityChange`, `onRemove` | default, stock-adjusted-notice | Cart |
| `CartSummaryPanel` | Subtotal/discount/tax/total breakdown | `inline`, `sticky-panel` | `summary` | default | Cart, Order Review |
| `OrderStatusBadge` | Color-coded order status pill | one per `OrderStatus` value | `status` | — | Order History/Detail, Admin Order Management |
| `OrderTrackingTimeline` | Chronological status/event timeline | — | `events` | default | Order Detail |
| `BannerCarousel` | Auto-rotating promotional banner | — | `banners`, `onTap` | loading, loaded, empty (hidden) | Home |
| `FeaturedCategoryRow` / `FeaturedProductRow` | Horizontal scroll showcase row | — | `items`, `onSeeAll` | loading, loaded, empty (hidden) | Home |

## 8. Loading Widgets

| Component | Purpose | Variants | Key Props | Used In |
|---|---|---|---|---|
| `AppLoadingIndicator` | Generic spinner | `small`, `medium`, `overlay` | `message?` | Buttons, full-screen loads |
| `ShimmerPlaceholder` | Skeleton loading block | `card`, `list-tile`, `text-line`, `image` | `width`, `height` | Product Card grid loading, list loading, dashboard KPI loading |
| `PaginationLoader` | Bottom-of-list "loading more" indicator | — | — | Product Grid, Order History, Admin tables |

## 9. Empty State

| Component | Purpose | Key Props | Used In |
|---|---|---|---|
| `AppEmptyState` | Generic empty-state block (illustration + message + optional CTA) | `illustration`, `title`, `message`, `ctaLabel?`, `onCtaPressed?` | Every list/detail screen's empty case (Cart, Wishlist, Orders, Search Results, Admin tables, etc.) — copy is sourced via `TenantConfig.copyOverrides` per Rule 37 |

## 10. Error State

| Component | Purpose | Key Props | Used In |
|---|---|---|---|
| `AppErrorState` | Generic error block with retry | `title`, `message` (from `FailureMessageMapper`), `onRetry` | Every async screen's error case |
| `AppInlineErrorBanner` | Compact inline error (form/section-level, non-full-screen) | `message`, `onDismiss?` | Form-level failures, partial-section failures (e.g., one home section fails while others load) |
| `NetworkOfflineBanner` | Persistent banner when connectivity is lost | — | Global app-shell overlay (both apps) |

## 11. Badges

| Component | Purpose | Variants | Key Props | Used In |
|---|---|---|---|---|
| `AppBadge` | Generic count/status badge | `dot`, `count`, `label` | `value?`, `color` | Cart badge, Notification bell, Low-stock badge |
| `LowStockBadge` | Stock-level warning indicator | `low`, `out-of-stock` | `quantity` | Admin Inventory, Product Management |
| `RoleBadge` | Admin role indicator | one per `AdminRole` | `role` | Admin shell header |
| `TicketStatusBadge` | Support ticket status pill | one per ticket status | `status` | Support |

## 12. Navigation

| Component | Purpose | Variants | Key Props | Used In |
|---|---|---|---|---|
| `AppTopBar` | Primary app bar | `standard`, `withSearch`, `transparent-scroll` | `title?`, `actions`, `leading?` | All screens |
| `AppBottomNavBar` | Customer app bottom navigation | — | `items`, `currentIndex`, `onTap`, badges per item | `apps/storefront` shell |
| `AppSideNav` | Admin app side navigation | `expanded`, `collapsed` (responsive) | `items` (role-filtered), `currentRoute` | `apps/admin` shell |
| `AppTabBar` | Secondary in-page tab navigation | — | `tabs`, `currentIndex`, `onTap` | Category chips, FAQ categories, Marketing tabs |
| `CategoryBreadcrumb` | Hierarchical path navigation | — | `path`, `onSegmentTap` | Category Detail |
| `StepperHeader` | Multi-step wizard progress indicator | — | `steps`, `currentStep` | Checkout |

## 13. Headers & Footers

| Component | Purpose | Key Props | Used In |
|---|---|---|---|
| `ProfileHeader` | Avatar + name + summary block | `user` | Profile Overview |
| `SettingsSectionHeader` | Section label divider | `title` | Settings, Admin forms |
| `AppFooter` (Web only) | Tenant-configurable footer (links, copyright, social) | `tenantConfig` | `apps/storefront` Web build |

## 14. Pagination

| Component | Purpose | Variants | Key Props | Used In |
|---|---|---|---|---|
| `AppPaginationControl` | Explicit page-number navigation (admin tables) | `numbered`, `prev-next` | `currentPage`, `totalPages`, `onPageChange` | `AdminDataTable` |
| `InfiniteScrollTrigger` | Invisible load-more trigger for lazy pagination | — | `onTriggered` | Product Grid, customer-facing lists |

## 15. Tables (Admin)

| Component | Purpose | Variants | Key Props | Used In |
|---|---|---|---|---|
| `AdminDataTable` | Responsive data table with sort/select/row-actions | `selectable`, `readonly` | `columns`, `rows`, `onSort`, `onRowTap`, `bulkActions?` | Product/Category/Order/Customer/Promotion management |
| `BulkActionToolbar` | Contextual toolbar shown when rows selected | — | `selectedCount`, `actions` | Admin Catalog |
| `TableEmptyRow` | Zero-rows placeholder within table shell | — | `message`, `ctaLabel?` | All admin tables |

## 16. Charts

| Component | Purpose | Variants | Key Props | Used In |
|---|---|---|---|---|
| `LineChartCard` | Trend-over-time visualization | — | `series`, `xLabels` | Admin Dashboard, Analytics Detail |
| `BarChartCard` | Categorical comparison visualization | `vertical`, `horizontal` | `data` | Analytics Detail, Reports |
| `DonutChartCard` | Proportional breakdown | — | `segments` | Admin Dashboard (e.g., order status distribution) |
| `TopProductsTable` | Ranked mini-table (chart-adjacent) | — | `products` | Admin Dashboard |

## 17. Feedback

| Component | Purpose | Variants | Key Props | Used In |
|---|---|---|---|---|
| `AppSnackbar` | Transient confirmation/info/error toast | `success`, `info`, `warning`, `error` | `message`, `actionLabel?`, `onAction?` | Add-to-cart confirmation, save confirmations, non-blocking errors |
| `AppBanner` | Persistent in-page announcement | `info`, `warning`, `error` | `message`, `onDismiss?` | Maintenance notices, offline banner, tenant announcements |

---

## 18. Cross-Cutting Component Rules

- **Every list-rendering component** (`ProductGrid`, `AdminDataTable`, `ReviewList`, etc.) accepts and renders all three of: loading (via `ShimmerPlaceholder`), empty (via `AppEmptyState`), and error (via `AppErrorState`) — this is enforced structurally by having these components accept a sealed `ListViewState<T>` rather than a raw `List<T>`, so a screen cannot forget to handle a state.
- **Every component is theme-aware, not tenant-aware.** Components read `Theme.of(context)`/`AppTheme` extensions; they never read `TenantConfig` directly. `TenantConfig` flows into `AppTheme` once, upstream (see `05_ARCHITECTURE_GUIDELINES.md` §15). This keeps components portable and testable with any arbitrary theme in widget tests.
- **Every component is documented with a `///` doc comment and a short usage example** in its source file header, per `06_DEVELOPMENT_RULES.md` Rule 29.
- **New components are proposed here first.** Adding a new reusable widget mid-feature-development requires updating this document in the same change, keeping it authoritative rather than aspirational.
- **A component's public API (constructor parameters) is considered a breaking-change surface.** Changing it requires checking every consumer listed in its "Used In" column above.
