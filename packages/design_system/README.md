# design_system

Design tokens, theming, and the shared reusable component library for the
White Label Commerce Platform. Consumed by both `apps/storefront` and
`apps/admin`. Depends only on `core` (see `docs/02_PROJECT_STRUCTURE.md` §5).

See `docs/08_COMPONENT_LIBRARY.md` for the full component specification.

## What's here (Phase 4)

| Folder | Contents |
|---|---|
| `tokens/` | `AppColors`, `AppTypography`, `AppSpacing`, `AppRadii`, `AppElevation`, `AppBreakpoints` |
| `theme/` | `AppTheme` (builds `ThemeData` from `TenantConfig`) + `AppSemanticColors` `ThemeExtension` |
| `components/` | Buttons, cards, dialogs, bottom sheets, inputs, chips, states, feedback, navigation, tables, charts |
| `layout/` | `ResponsiveLayoutBuilder` |
| `state/` | `ListViewState<T>` sealed helper for loading/empty/error/loaded list UIs |
| `gallery/` | Dev-only `DesignSystemGallery` (light/dark + two mock tenants) |

Components are **theme-aware, not tenant-aware**: they read `Theme.of(context)` /
`AppSemanticColors` only — never `TenantConfig` directly
(`docs/08_COMPONENT_LIBRARY.md` §18).

Feature-specific commerce widgets (`ProductCard`, `OrderCard`, etc.) live in
their owning feature packages, not here.

## Gallery

In `dev`/`staging` flavors both apps home to `DesignSystemGallery` when
`AppConfig.isDeveloperModeAvailable` is true. Toggle light/dark and switch
between the default and Acme mock tenants from the app bar.
