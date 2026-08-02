/// Design tokens, theming, and the shared reusable component library for the
/// White Label Commerce Platform.
///
/// Consumed by both `apps/storefront` and `apps/admin`. Components here read
/// `Theme.of(context)`/`AppTheme` only - never `TenantConfig` directly
/// (see docs/05_ARCHITECTURE_GUIDELINES.md §17 and
/// docs/08_COMPONENT_LIBRARY.md §18).
///
/// Populated across Phase 4 ("Design System & Shared Widgets") milestones per
/// docs/03_DEVELOPMENT_PHASES.md.
library;

export 'components/bottom_sheets/app_action_sheet.dart';
export 'components/bottom_sheets/app_filter_bottom_sheet.dart';
export 'components/bottom_sheets/app_language_picker_sheet.dart';
export 'components/bottom_sheets/app_sort_bottom_sheet.dart';
export 'components/buttons/app_button.dart';
export 'components/buttons/app_floating_action_button.dart';
export 'components/buttons/app_icon_button.dart';
export 'components/buttons/app_text_link_button.dart';
export 'components/cards/app_address_card.dart';
export 'components/cards/app_card.dart';
export 'components/cards/app_kpi_card.dart';
export 'components/charts/app_bar_chart_card.dart';
export 'components/charts/app_donut_chart_card.dart';
export 'components/charts/app_line_chart_card.dart';
export 'components/charts/app_top_products_table.dart';
export 'components/charts/chart_models.dart';
export 'components/chips/active_filter_chip_row.dart';
export 'components/chips/app_filter_chip.dart';
export 'components/chips/recent_search_chip.dart';
export 'components/chips/search_suggestion_tile.dart';
export 'components/dialogs/app_alert_dialog.dart';
export 'components/feedback/app_banner.dart';
export 'components/feedback/app_snackbar.dart';
export 'components/inputs/app_dropdown.dart';
export 'components/inputs/app_search_bar.dart';
export 'components/inputs/app_text_field.dart';
export 'components/inputs/auth_text_field.dart';
export 'components/inputs/otp_input_row.dart';
export 'components/inputs/password_strength_indicator.dart';
export 'components/inputs/promo_code_field.dart';
export 'components/inputs/quantity_stepper.dart';
export 'components/navigation/app_bottom_nav_bar.dart';
export 'components/navigation/app_category_breadcrumb.dart';
export 'components/navigation/app_side_nav.dart';
export 'components/navigation/app_stepper_header.dart';
export 'components/navigation/app_tab_bar.dart';
export 'components/navigation/app_top_bar.dart';
export 'components/states/app_empty_state.dart';
export 'components/states/app_error_state.dart';
export 'components/states/app_inline_error_banner.dart';
export 'components/states/app_loading_indicator.dart';
export 'components/states/network_offline_banner.dart';
export 'components/states/pagination_loader.dart';
export 'components/states/shimmer_placeholder.dart';
export 'components/tables/app_bulk_action_toolbar.dart';
export 'components/tables/app_data_table.dart';
export 'components/tables/app_pagination_control.dart';
export 'components/tables/app_table_empty_row.dart';
export 'gallery/design_system_gallery.dart';
export 'layout/responsive_layout_builder.dart';
export 'state/list_view_state.dart';
export 'theme/app_theme.dart';
export 'theme/theme_extensions.dart';
export 'tokens/app_breakpoints.dart';
export 'tokens/app_colors.dart';
export 'tokens/app_elevation.dart';
export 'tokens/app_radii.dart';
export 'tokens/app_spacing.dart';
export 'tokens/app_typography.dart';
