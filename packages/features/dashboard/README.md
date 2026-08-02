# dashboard

Post-login landing surface for the customer storefront (Home).

See `docs/04_FEATURE_IMPLEMENTATION_ORDER.md` §2 and Phase 8 of
`docs/03_DEVELOPMENT_PHASES.md`.

## Package layout

```
lib/
  dashboard.dart               # public barrel
  src/domain/                  # HomeFeed entities, GetHomeFeed
  src/data/                    # mock gateways + repository
  src/presentation/            # HomeBloc, HomeScreen, feature widgets
  src/injection/               # configureDashboardInjection()
```

## Phase 8 deviation

Feature order says Home composes `ProductRepository` / `CategoryRepository` /
`BannerRepository`. Those packages are empty stubs until Phases 9–10 / 25.

This package defines local view models and thin gateways that read
`MockSeedStore` / a hardcoded banner seed instead of cross-feature imports.

## Bootstrap

```dart
configureMockInjection();
await configureAuthenticationInjection();
configureDashboardInjection();
```

## Demo

1. Run storefront (`apps/storefront`, `main_dev.dart`).
2. Complete onboarding if needed, login as `noah.patel02@example.com` /
   `Password123!`.
3. Land on **Home** with banners, categories, and featured products.
