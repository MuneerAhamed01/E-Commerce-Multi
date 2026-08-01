# 10 — Data Flow

**Status:** Planning document. Documents how data moves through the system today (Mock) and how that flow changes when Firebase is integrated later, so the transition is a pure implementation swap.

---

## 1. The Canonical Flow (Phase 1, Mock)

```
Mock Fixture Data (in-memory / static Dart data)
        │
        ▼
Mock Data Source  (implements <Feature>RemoteDataSource interface)
   - simulates latency (300–800ms configurable)
   - simulates failures (dev-panel/query-param triggerable)
        │  throws <Feature>Exception on simulated failure
        ▼
Repository Implementation  (Mock<Feature>RepositoryImpl, implements domain <Feature>Repository)
   - try/catch around data source calls (ONLY place exceptions are caught)
   - maps DataSource Exception → typed Failure
   - maps Model (DTO) → Entity
   - returns Future<Result<Failure, Entity>> or PaginatedResult<Entity>
        │
        ▼
Use Case  (single call() method, e.g. GetProductDetail)
   - orchestrates one or more repository calls
   - applies any pure business rule not itself worth a repository method
   - returns Result<Failure, T> unchanged in shape
        │
        ▼
Bloc / Cubit
   - calls use case in response to an Event/method call
   - maps Result to a State (Loading → Loaded(data) | Error(failure))
        │  emits State
        ▼
UI (Screen / Widget)
   - BlocBuilder/BlocListener renders Loading/Loaded/Empty/Error per State
   - never touches Result, Failure translation, or the repository layer directly
```

This exact chain is identical for **every** feature in the platform — see `04_FEATURE_IMPLEMENTATION_ORDER.md`'s per-feature "Business Logic / Repositories / Models / State Management" fields, which are all instances of this one pattern.

## 2. Mock Repository Design Rules

- Every `Mock*RepositoryImpl` holds its fixture data in a single, feature-owned in-memory store (a simple `List<Model>`/`Map<id, Model>` held by a singleton, registered via DI as `registerLazySingleton`), **not** re-read from disk/JSON on every call — this keeps admin mutations (Phase 23–26) visible to the storefront within the same running session, matching the acceptance criteria in `04_FEATURE_IMPLEMENTATION_ORDER.md` §17 and §21.
- Latency simulation and failure injection are implemented once, as a shared `MockNetworkSimulator` utility in `core`, reused by every feature's mock data source rather than reimplemented per feature (consistency + a single place to tune QA behavior).
- Mock data sources never import `flutter_bloc` or any presentation-layer type — they are plain Dart, testable without a widget harness, and reusable verbatim if the mock layer is ever needed for automated integration tests.

## 3. Repository Interface Contract (Template)

Every repository interface follows this shape, so the eventual Firebase implementation has an unambiguous target:

```dart
abstract class ProductRepository {
  Future<Result<Failure, PaginatedResult<Product>>> getProducts({
    required PageRequest page,
    ProductFilter? filter,
  });

  Future<Result<Failure, Product>> getProductDetail(String productId);

  Future<Result<Failure, PaginatedResult<Product>>> getRelatedProducts(
    String productId, {
    required PageRequest page,
  });

  Stream<Result<Failure, PaginatedResult<Review>>> watchReviews(
    String productId,
  );

  Future<Result<Failure, Unit>> submitReview(Review review);
}
```

Notes on why each shape choice was made:

- `PageRequest`/`PaginatedResult<T>` — mirrors Firestore's cursor pagination (`startAfterDocument`) rather than offset pagination, which does not scale on Firestore.
- `Stream` for `watchReviews` — reviews are a realtime-shaped concern (new reviews should appear without a manual refresh); the mock implementation backs this with a `StreamController` fed by local mutations, and Firestore's `snapshots()` slots in later with zero Bloc-side changes.
- `Result<Failure, Unit>` for a fire-and-forget mutation — expresses "this can fail" without inventing a meaningless return payload.

## 4. Bloc/Cubit Consumption Pattern

```dart
class ProductDetailBloc extends Bloc<ProductDetailEvent, ProductDetailState> {
  ProductDetailBloc(this._getProductDetail, this._getRelatedProducts)
      : super(const ProductDetailState.initial()) {
    on<ProductDetailRequested>(_onRequested);
  }

  final GetProductDetail _getProductDetail;
  final GetRelatedProducts _getRelatedProducts;

  Future<void> _onRequested(
    ProductDetailRequested event,
    Emitter<ProductDetailState> emit,
  ) async {
    emit(const ProductDetailState.loading());
    final result = await _getProductDetail(event.productId);
    result.fold(
      (failure) => emit(ProductDetailState.error(failure)),
      (product) => emit(ProductDetailState.loaded(product)),
    );
  }
}
```

This is the only shape a Bloc is allowed to take when consuming data: construct with **use cases** (never repositories directly, per `06_DEVELOPMENT_RULES.md` Rule 2), `await` the call, `.fold()` the `Result` into a state. This pattern is identical across all ~30 Blocs in the platform.

## 5. Caching Strategy (Phase 1)

- **In-memory only, feature-scoped.** Each mock repository's in-memory store *is* the cache for Phase 1 — there is no separate caching layer yet because there is no remote source to cache against.
- **Cross-session persistence** (survives app restart) is limited to what genuinely needs it in Phase 1: Auth session, Cart contents, Settings/theme/locale preference, Recent Searches, Developer Panel state — implemented via `shared_preferences` (simple key-value) or `hive` (structured, for Cart) behind the same repository-interface pattern (a `LocalPersistenceDataSource`, not a special case).
- **Cache invalidation policy for the future backend phase** (documented now, not built now): repositories will gain an optional local cache layer (`Hive`/`Isar`) sitting between the Bloc and the remote data source, with a cache-then-network or stale-while-revalidate strategy determined per feature based on data volatility (e.g., Product catalog: cache-first with TTL; Cart/Orders: network-first, cache is a fallback only).

## 6. Offline Strategy

- **Phase 1 posture:** The app is mock-data-driven and technically "offline-capable" by default since there is no network dependency yet. The `NetworkOfflineBanner` (design system) and `NetworkInfo` abstraction (`core`) are built now against the device's actual connectivity state so the UX pattern exists and is tested, even though no real request is blocked by it yet.
- **Documented future strategy (for the backend-integration phase):**
  - Read-heavy, low-volatility data (Products, Categories, FAQ) — served from local cache when offline, with a visible "showing saved data" indicator.
  - Write operations attempted while offline (Add to Cart, Place Order, Submit Review) — Phase 1 mock behavior fails fast with a clear error (`NetworkOfflineFailure`) rather than silently queuing; a future offline-write-queue (outbox pattern) is an explicitly flagged **future enhancement**, not a Phase 1 or immediate-post-Firebase-integration deliverable, given its complexity (conflict resolution, idempotency) relative to priority.
  - Session/auth state always available offline once previously established (no forced re-login purely due to connectivity loss).

## 7. Anticipated Firestore Collection Map (for future backend integration)

This is **not built** in this plan's scope but is fixed now so mock DTOs are designed to mirror it directly (per `05_ARCHITECTURE_GUIDELINES.md` §18):

| Collection | Document Shape (top-level fields) | Notes |
|---|---|---|
| `tenants/{tenantId}` | branding, copyOverrides, featureFlags, contactInfo | Root of multi-tenant data partitioning |
| `tenants/{tenantId}/users/{userId}` | profile fields, role, status | Mirrors `User`/`Profile`/`AdminRole` |
| `tenants/{tenantId}/products/{productId}` | product fields, variants (sub-map or subcollection `variants/{variantId}`), stock | Mirrors `Product`/`ProductVariant`/`StockLevel` |
| `tenants/{tenantId}/products/{productId}/reviews/{reviewId}` | rating, text, authorId, createdAt | Mirrors `Review` |
| `tenants/{tenantId}/categories/{categoryId}` | name, parentId, sortOrder | Mirrors `Category` |
| `tenants/{tenantId}/users/{userId}/addresses/{addressId}` | address fields | Shared `Address` entity |
| `tenants/{tenantId}/users/{userId}/paymentMethods/{methodId}` | masked method fields | Mirrors `PaymentMethod` (never raw card data — real PCI-sensitive data belongs with the payment provider, not Firestore) |
| `tenants/{tenantId}/users/{userId}/wishlist/{productId}` | addedAt | Mirrors `WishlistItem` |
| `tenants/{tenantId}/users/{userId}/cart/items/{itemId}` | productId, variantId, quantity | Mirrors `CartItem`; `Cart` aggregate computed, not stored |
| `tenants/{tenantId}/orders/{orderId}` | customerId, lineItems, status, totals, addresses | Mirrors `Order` |
| `tenants/{tenantId}/orders/{orderId}/trackingEvents/{eventId}` | status, timestamp, note | Mirrors `OrderTrackingEvent` |
| `tenants/{tenantId}/coupons/{couponCode}` | discount rules, expiry, usage | Mirrors `Coupon` |
| `tenants/{tenantId}/banners/{bannerId}` | image, target, activeWindow, sortOrder | Mirrors `Banner` |
| `tenants/{tenantId}/notifications/{userId}/items/{notificationId}` | category, payload, readAt | Mirrors `AppNotification` |
| `tenants/{tenantId}/supportTickets/{ticketId}` | customerId, status, messages | Mirrors `SupportTicket` |
| `tenants/{tenantId}/faq/{faqId}` | category, question, answer | Mirrors `FaqItem` |

`tenantId` partitioning at the root of every collection is the mechanism that makes this schema multi-tenant-ready at the data layer, matching the `TenantConfig` partitioning already present at the application-config layer.

## 8. Future Firebase Integration — Swap Mechanics

1. Add `Firebase<Feature>DataSource implements <Feature>RemoteDataSource` inside the same `data/datasources/` folder, next to the existing mock one.
2. Add `firebase_options.dart` per environment (see `11_ENVIRONMENT_CONFIGURATION.md`).
3. Change exactly one line per feature in its `<Feature>InjectionModule`: the `dataSourceMode == mock ? MockXDataSource() : FirebaseXDataSource()` branch (already present as a no-op-today conditional, per `05_ARCHITECTURE_GUIDELINES.md` §7).
4. `RepositoryImpl`, use cases, Blocs, and every screen require **zero** changes — this is the measurable proof of the architecture's success criteria (`01_IMPLEMENTATION_PLAN.md` §14).
5. Run the full `12_MANUAL_TEST_PLAN.md` again against the Firebase-backed build as regression verification before that (separately scoped) integration project is considered complete.

## 9. Data Flow Diagram (Textual, End-to-End Including Future State)

```
                 ┌────────────────────┐        ┌───────────────────────┐
                 │   Mock Data Source  │  OR    │  Firebase Data Source  │   (selected via DI @ bootstrap)
                 └──────────┬──────────┘        └───────────┬───────────┘
                            └───────────────┬────────────────┘
                                            ▼
                                 Repository Implementation
                                 (translates Model→Entity,
                                  Exception→Failure)
                                            ▼
                                        Use Case
                                            ▼
                                      Bloc / Cubit
                                            ▼
                                    Screen / Widget
                                    (Loading/Loaded/
                                     Empty/Error UI)
```

The presentation and domain layers are drawn identically regardless of which data source is active — that invariance is the architecture's core deliverable.
