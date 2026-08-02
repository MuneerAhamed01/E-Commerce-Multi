import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/dashboard_kpi_set.dart';
import '../bloc/admin_dashboard_bloc.dart';

/// Admin at-a-glance KPI dashboard (Phase 8 shell; full analytics in Phase 22).
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key, this.adminDashboardBloc});

  /// Optional override for tests; defaults to `getIt<AdminDashboardBloc>()`.
  final AdminDashboardBloc? adminDashboardBloc;

  static Widget provided({AdminDashboardBloc? adminDashboardBloc}) {
    return AdminDashboardScreen(adminDashboardBloc: adminDashboardBloc);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          (adminDashboardBloc ?? getIt<AdminDashboardBloc>())
            ..add(const AdminDashboardStarted()),
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<AdminDashboardBloc, AdminDashboardState>(
            builder: (context, state) {
              return switch (state) {
                AdminDashboardInitial() ||
                AdminDashboardLoading() => const _DashboardSkeleton(),
                AdminDashboardError(:final message) => AppErrorState(
                  title: 'Could not load dashboard',
                  message: message,
                  onRetry: () => context.read<AdminDashboardBloc>().add(
                    const AdminDashboardRetried(),
                  ),
                ),
                AdminDashboardLoaded(:final kpis) => RefreshIndicator(
                  onRefresh: () async {
                    context.read<AdminDashboardBloc>().add(
                      const AdminDashboardRetried(),
                    );
                    await context.read<AdminDashboardBloc>().stream.firstWhere(
                      (s) =>
                          s is AdminDashboardLoaded || s is AdminDashboardError,
                    );
                  },
                  child: kpis.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 120),
                            AppEmptyState(
                              title: 'No store activity yet',
                              message:
                                  'KPIs and charts will appear once orders and '
                                  'catalog data are available.',
                            ),
                          ],
                        )
                      : _DashboardBody(kpis: kpis),
                ),
              };
            },
          ),
        ),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.kpis});

  final DashboardKpiSet kpis;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final trend = kpis.salesDeltaPercent;
    final trendDirection = trend > 0.5
        ? AppKpiTrend.positive
        : trend < -0.5
        ? AppKpiTrend.negative
        : AppKpiTrend.neutral;

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        final crossAxisCount = wide ? 4 : 2;

        return ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text('Dashboard', style: textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.sm),
            Text('Store health at a glance', style: textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.lg),
            GridView.count(
              crossAxisCount: crossAxisCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              childAspectRatio: wide ? 1.6 : 1.35,
              children: [
                AppKpiCard(
                  label: 'Total sales',
                  value: Formatters.currency(kpis.totalSales),
                  deltaPercent: trend.abs(),
                  trend: trendDirection,
                  icon: Icons.payments_outlined,
                ),
                AppKpiCard(
                  label: 'Orders',
                  value: Formatters.compactNumber(kpis.orderCount),
                  icon: Icons.receipt_long_outlined,
                ),
                AppKpiCard(
                  label: 'Avg. order value',
                  value: Formatters.currency(kpis.averageOrderValue),
                  icon: Icons.shopping_cart_outlined,
                ),
                AppKpiCard(
                  label: 'Conversion',
                  value: Formatters.percentage(kpis.conversionRate),
                  icon: Icons.trending_up,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            AppLineChartCard(
              title: 'Sales trend (recent days)',
              xLabels: [for (final p in kpis.salesTrend) p.label],
              series: [
                AppChartSeries(
                  label: 'Revenue',
                  values: [
                    for (final p in kpis.salesTrend) p.revenue.majorUnits,
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: [
                AppKpiCard(
                  label: 'Catalog products',
                  value: Formatters.compactNumber(kpis.catalogProductCount),
                  icon: Icons.inventory_2_outlined,
                ),
                AppKpiCard(
                  label: 'Out of stock',
                  value: Formatters.compactNumber(kpis.lowStockCount),
                  trend: kpis.lowStockCount > 0
                      ? AppKpiTrend.negative
                      : AppKpiTrend.neutral,
                  icon: Icons.warning_amber_outlined,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: const [
        AppShimmerPlaceholder(width: 160, height: 28),
        SizedBox(height: AppSpacing.sm),
        AppShimmerPlaceholder(width: 220, height: 16),
        SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: AppKpiCard(label: '', value: '', isLoading: true),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppKpiCard(label: '', value: '', isLoading: true),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: AppKpiCard(label: '', value: '', isLoading: true),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppKpiCard(label: '', value: '', isLoading: true),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.xl),
        AppShimmerPlaceholder(variant: AppShimmerVariant.card, height: 200),
      ],
    );
  }
}
