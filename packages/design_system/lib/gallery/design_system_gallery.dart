import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../components/buttons/app_button.dart';
import '../components/buttons/app_icon_button.dart';
import '../components/buttons/app_text_link_button.dart';
import '../components/cards/app_card.dart';
import '../components/cards/app_kpi_card.dart';
import '../components/charts/app_bar_chart_card.dart';
import '../components/charts/app_donut_chart_card.dart';
import '../components/charts/app_line_chart_card.dart';
import '../components/charts/chart_models.dart';
import '../components/chips/app_filter_chip.dart';
import '../components/feedback/app_banner.dart';
import '../components/feedback/app_snackbar.dart';
import '../components/inputs/app_text_field.dart';
import '../components/inputs/quantity_stepper.dart';
import '../components/navigation/app_stepper_header.dart';
import '../components/navigation/app_tab_bar.dart';
import '../components/states/app_empty_state.dart';
import '../components/states/app_error_state.dart';
import '../components/states/app_loading_indicator.dart';
import '../components/states/shimmer_placeholder.dart';
import '../components/tables/app_pagination_control.dart';
import '../theme/app_theme.dart';
import '../tokens/app_spacing.dart';

/// Dev-only gallery that renders a representative sample of every shared
/// component category against two mock tenant configs and both light/dark
/// themes - the Phase 4 completion criterion in
/// docs/03_DEVELOPMENT_PHASES.md.
///
/// Feature-specific commerce widgets (`ProductCard`, `OrderCard`, etc.) are
/// intentionally absent: they live in their owning feature packages and are
/// not part of the shared design-system surface (docs/08_COMPONENT_LIBRARY.md
/// §7 / docs/02_PROJECT_STRUCTURE.md §5).
class DesignSystemGallery extends StatefulWidget {
  const DesignSystemGallery({super.key});

  @override
  State<DesignSystemGallery> createState() => _DesignSystemGalleryState();
}

class _DesignSystemGalleryState extends State<DesignSystemGallery> {
  bool _useDark = false;
  bool _useAltTenant = false;
  bool _filterSelected = true;
  int _quantity = 1;
  int _tabIndex = 0;
  int _page = 1;

  TenantConfig get _tenant => _useAltTenant ? _acmeTenant : _defaultTenant;

  @override
  Widget build(BuildContext context) {
    final theme = _useDark ? AppTheme.dark(_tenant) : AppTheme.light(_tenant);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: Builder(
        builder: (galleryContext) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Design System — ${_tenant.displayName}'),
              actions: [
                IconButton(
                  tooltip: _useDark ? 'Switch to light' : 'Switch to dark',
                  onPressed: () => setState(() => _useDark = !_useDark),
                  icon: Icon(_useDark ? Icons.light_mode : Icons.dark_mode),
                ),
                IconButton(
                  tooltip: 'Switch tenant',
                  onPressed: () =>
                      setState(() => _useAltTenant = !_useAltTenant),
                  icon: const Icon(Icons.swap_horiz),
                ),
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                _Section(
                  title: 'Buttons',
                  child: Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      AppButton(label: 'Primary', onPressed: () {}),
                      AppButton(
                        label: 'Secondary',
                        variant: AppButtonVariant.secondary,
                        onPressed: () {},
                      ),
                      AppButton(
                        label: 'Outline',
                        variant: AppButtonVariant.outline,
                        onPressed: () {},
                      ),
                      AppButton(
                        label: 'Destructive',
                        variant: AppButtonVariant.destructive,
                        onPressed: () {},
                      ),
                      AppButton(
                        label: 'Loading',
                        onPressed: () {},
                        isLoading: true,
                      ),
                      AppIconButton(
                        icon: Icons.favorite_border,
                        tooltip: 'Wishlist',
                        onPressed: () {},
                      ),
                      AppTextLinkButton(label: 'View all', onPressed: () {}),
                    ],
                  ),
                ),
                _Section(
                  title: 'Inputs',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const AppTextField(
                        label: 'Email',
                        hint: 'you@example.com',
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppQuantityStepper(
                        value: _quantity,
                        min: 1,
                        max: 5,
                        onChanged: (value) => setState(() => _quantity = value),
                      ),
                    ],
                  ),
                ),
                _Section(
                  title: 'Chips',
                  child: Wrap(
                    spacing: AppSpacing.sm,
                    children: [
                      AppFilterChip(
                        label: 'In stock',
                        selected: _filterSelected,
                        onTap: (selected) =>
                            setState(() => _filterSelected = selected),
                      ),
                      AppFilterChip(
                        label: 'On sale',
                        selected: false,
                        onTap: (_) {},
                      ),
                    ],
                  ),
                ),
                _Section(
                  title: 'Cards',
                  child: Column(
                    children: [
                      AppCard(
                        child: Text(
                          'Outlined card on ${_tenant.displayName}',
                          style: Theme.of(galleryContext).textTheme.bodyMedium,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const AppKpiCard(
                        label: 'Revenue',
                        value: r'$12.4k',
                        deltaPercent: 8.2,
                      ),
                    ],
                  ),
                ),
                _Section(
                  title: 'States & feedback',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const AppLoadingIndicator(message: 'Loading…'),
                      const SizedBox(height: AppSpacing.sm),
                      const AppShimmerPlaceholder(
                        variant: AppShimmerVariant.card,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppEmptyState(
                        title: 'Nothing here yet',
                        message: 'Try adjusting filters or adding an item.',
                        ctaLabel: 'Browse',
                        onCtaPressed: () {},
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppErrorState(
                        title: 'Something went wrong',
                        message: 'Please try again.',
                        onRetry: () {},
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppBanner(
                        message: 'Maintenance window tonight 22:00–23:00 UTC.',
                        onDismiss: () {},
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppButton(
                        label: 'Show snackbar',
                        onPressed: () => AppSnackbar.show(
                          galleryContext,
                          message: 'Saved successfully',
                          variant: AppSnackbarVariant.success,
                        ),
                      ),
                    ],
                  ),
                ),
                _Section(
                  title: 'Navigation',
                  child: Column(
                    children: [
                      AppTabBar(
                        tabs: const ['Overview', 'Orders', 'Customers'],
                        currentIndex: _tabIndex,
                        onTap: (index) => setState(() => _tabIndex = index),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppStepperHeader(
                        steps: const [
                          'Address',
                          'Shipping',
                          'Payment',
                          'Review',
                        ],
                        currentStep: 1,
                      ),
                    ],
                  ),
                ),
                _Section(
                  title: 'Tables',
                  child: AppPaginationControl(
                    currentPage: _page,
                    totalPages: 5,
                    onPageChange: (page) => setState(() => _page = page),
                  ),
                ),
                const _Section(
                  title: 'Charts',
                  child: Column(
                    children: [
                      AppLineChartCard(
                        title: 'Orders',
                        xLabels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
                        series: [
                          AppChartSeries(
                            label: 'Orders',
                            values: [12, 18, 9, 22, 16],
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.sm),
                      AppBarChartCard(
                        title: 'By category',
                        data: [
                          AppChartDatum(label: 'Apparel', value: 40),
                          AppChartDatum(label: 'Home', value: 28),
                          AppChartDatum(label: 'Beauty', value: 18),
                        ],
                      ),
                      SizedBox(height: AppSpacing.sm),
                      AppDonutChartCard(
                        title: 'Order status',
                        segments: [
                          AppChartSegment(label: 'Fulfilled', value: 62),
                          AppChartSegment(label: 'Pending', value: 24),
                          AppChartSegment(label: 'Cancelled', value: 14),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          child,
        ],
      ),
    );
  }
}

final _defaultTenant = TenantConfig(
  tenantId: 'default',
  displayName: 'White Label Commerce Platform',
  branding: const BrandingTokens(
    primaryColorHex: '#2563EB',
    secondaryColorHex: '#F97316',
    logoAssetPath: 'assets/branding/default_logo.png',
  ),
  copy: const CopyOverrides.empty(),
  featureFlags: FeatureFlagSet.allEnabled(),
  defaultLocale: 'en_US',
  supportEmail: 'support@example.com',
  allowGuestBrowsing: true,
  allowGuestCart: true,
);

final _acmeTenant = TenantConfig(
  tenantId: 'acme',
  displayName: 'Acme Commerce',
  branding: const BrandingTokens(
    primaryColorHex: '#0F766E',
    secondaryColorHex: '#BE123C',
    logoAssetPath: 'assets/branding/acme_logo.png',
    fontFamily: 'Roboto',
  ),
  copy: const CopyOverrides.empty(),
  featureFlags: FeatureFlagSet.allEnabled(),
  defaultLocale: 'en_US',
  supportEmail: 'hello@acme.example',
  allowGuestBrowsing: true,
  allowGuestCart: true,
);
