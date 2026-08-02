# admin_dashboard

Admin at-a-glance KPI dashboard.

See `docs/04_FEATURE_IMPLEMENTATION_ORDER.md` §16 and Phase 8 of
`docs/03_DEVELOPMENT_PHASES.md` (full analytics/reports remain Phase 22).

## Package layout

```
lib/
  admin_dashboard.dart         # public barrel
  src/domain/                  # DashboardKpiSet, GetDashboardKpis
  src/data/                    # mock aggregation from MockSeedStore
  src/presentation/            # AdminDashboardBloc + screen
  src/injection/               # configureAdminDashboardInjection()
```

## Bootstrap

```dart
configureMockInjection();
await configureAuthenticationInjection();
configureAdminDashboardInjection();
```

## Demo

1. Run admin (`apps/admin`, `main_dev.dart`, Chrome recommended).
2. Login as `admin@example.com` / `Password123!`.
3. Land on **Dashboard** with KPI cards and a sales trend chart.
