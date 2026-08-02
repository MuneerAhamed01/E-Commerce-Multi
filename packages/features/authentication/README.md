# authentication

Establish and persist user identity for both customer and admin apps; gate
every protected route.

See `docs/04_FEATURE_IMPLEMENTATION_ORDER.md` §1 and Phase 7 of
`docs/03_DEVELOPMENT_PHASES.md`.

## Package layout

```
lib/
  authentication.dart          # public barrel
  src/domain/                  # entities, AuthRepository, use cases
  src/data/                    # mock remote + SharedPreferences local
  src/presentation/            # AuthBloc, form cubits, screens, routes
  src/injection/               # configureAuthenticationInjection()
```

## Demo credentials (mock)

| Role     | Email                         | Password       |
|----------|-------------------------------|----------------|
| Customer | `noah.patel02@example.com`    | `Password123!` |
| Admin    | `admin@example.com`           | `Password123!` |
| Support  | `support@example.com`         | `Password123!` |

All other `SeedData.users` emails also accept `Password123!`.

Mock OTP (non-prod): **`123456`**.

## Bootstrap

Call after mock DI in both apps:

```dart
configureMockInjection();
await configureAuthenticationInjection();
```

Wire `AuthBloc` at the app root with `AuthSessionListenable` as
`GoRouter.refreshListenable`, mapping session via `AuthSessionMapper`.

## Admin note

`/admin/login` uses the same use cases with `requireAdmin: true`. Customer
accounts receive an inline unauthorized error and never enter the admin shell.
Full `AdminRole` permission matrix is Phase 21.
