import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../components/buttons/app_button.dart';
import '../components/navigation/app_top_bar.dart';
import '../tokens/app_spacing.dart';
import 'ping_cubit.dart';

/// Dev-only scaffold: env/tenant summary, mock controls, and the reference
/// ping demo (docs/03_DEVELOPMENT_PHASES.md milestone 6.3).
///
/// Production routes resolve dependencies from [getIt]. Tests may pass
/// explicit instances to avoid sharing the global service locator.
class DeveloperPanelPage extends StatelessWidget {
  const DeveloperPanelPage({
    required this.appConfig,
    required this.tenantConfig,
    this.title = 'Developer Panel',
    this.getPing,
    this.controls,
    this.store,
    this.simulator,
    super.key,
  });

  final AppConfig appConfig;
  final TenantConfig tenantConfig;
  final String title;

  /// Optional overrides for tests; production uses [getIt].
  final GetPing? getPing;
  final MockDeveloperControls? controls;
  final MockSeedStore? store;
  final MockNetworkSimulator? simulator;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PingCubit(getPing ?? getIt<GetPing>()),
      child: _DeveloperPanelView(
        appConfig: appConfig,
        tenantConfig: tenantConfig,
        title: title,
        controls: controls ?? getIt<MockDeveloperControls>(),
        store: store ?? getIt<MockSeedStore>(),
        simulator: simulator ?? getIt<MockNetworkSimulator>(),
      ),
    );
  }
}

class _DeveloperPanelView extends StatefulWidget {
  const _DeveloperPanelView({
    required this.appConfig,
    required this.tenantConfig,
    required this.title,
    required this.controls,
    required this.store,
    required this.simulator,
  });

  final AppConfig appConfig;
  final TenantConfig tenantConfig;
  final String title;
  final MockDeveloperControls controls;
  final MockSeedStore store;
  final MockNetworkSimulator simulator;

  @override
  State<_DeveloperPanelView> createState() => _DeveloperPanelViewState();
}

class _DeveloperPanelViewState extends State<_DeveloperPanelView> {
  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controls = widget.controls;
    final store = widget.store;
    final simulator = widget.simulator;
    final counts = store.counts;

    return Scaffold(
      appBar: AppTopBar(title: widget.title),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Environment', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            _InfoRow(
              label: 'Environment',
              value: widget.appConfig.environment.name,
            ),
            _InfoRow(
              label: 'Data source',
              value: widget.appConfig.dataSourceMode.name,
            ),
            _InfoRow(label: 'Tenant', value: widget.tenantConfig.tenantId),
            _InfoRow(
              label: 'Display name',
              value: widget.tenantConfig.displayName,
            ),
            _InfoRow(
              label: 'Effective latency',
              value:
                  '${simulator.effectiveLatencyMin.inMilliseconds}-'
                  '${simulator.effectiveLatencyMax.inMilliseconds} ms'
                  '${controls.latencyDisabled ? ' (disabled)' : ''}',
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Seed inventory', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            _InfoRow(label: 'Categories', value: '${counts['categories']}'),
            _InfoRow(label: 'Products', value: '${counts['products']}'),
            _InfoRow(label: 'Users', value: '${counts['users']}'),
            _InfoRow(label: 'Orders', value: '${counts['orders']}'),
            const SizedBox(height: AppSpacing.xl),
            Text('Mock controls', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Disable mock latency'),
              subtitle: const Text('Skip artificial delay for snappy local QA'),
              value: controls.latencyDisabled,
              onChanged: (value) {
                controls.latencyDisabled = value;
                _refresh();
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Force ping failure'),
              subtitle: const Text('Call type: ping'),
              value: controls.shouldFail(MockCallTypes.ping),
              onChanged: (_) {
                controls.toggleFailure(MockCallTypes.ping);
                _refresh();
              },
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: 'Reset mock data',
              variant: AppButtonVariant.outline,
              onPressed: () {
                controls.resetMockData();
                _refresh();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mock seed data restored')),
                );
              },
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Reference ping', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Exercises domain -> mock data source -> repository -> '
              'use case -> cubit -> UI.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.md),
            BlocBuilder<PingCubit, PingState>(
              builder: (context, state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppButton(
                      label: 'Run ping',
                      isLoading: state is PingLoading,
                      onPressed: () => context.read<PingCubit>().ping(),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    switch (state) {
                      PingInitial() => Text(
                        'Idle - tap Run ping to exercise the mock stack.',
                        style: theme.textTheme.bodyMedium,
                      ),
                      PingLoading() => Text(
                        'Waiting on mock latency / response...',
                        style: theme.textTheme.bodyMedium,
                      ),
                      PingLoaded(:final message) => Text(
                        '${message.message}\n'
                        'products=${message.productCount}\n'
                        'servedAt=${message.servedAtIso}',
                        style: theme.textTheme.bodyMedium,
                      ),
                      PingError(:final failure) => Text(
                        'Failure: ${failure.runtimeType}'
                        '${failure.message != null ? ' - ${failure.message}' : ''}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    },
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: theme.textTheme.bodyMedium),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
