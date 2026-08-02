import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/search_suggestion.dart';
import '../bloc/search_bloc.dart';
import '../routing/search_routes.dart';

/// Search entry: bar + recent/trending + debounced suggestions.
///
/// Debounce (≥300ms) is owned by [AppSearchBar] (default 350ms) before
/// [SearchQueryChanged] reaches [SearchBloc].
class SearchEntryScreen extends StatelessWidget {
  const SearchEntryScreen({super.key, this.searchBloc});

  /// Optional override for tests; defaults to `getIt<SearchBloc>()`.
  final SearchBloc? searchBloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          (searchBloc ?? getIt<SearchBloc>())..add(const SearchStarted()),
      child: const _SearchEntryView(),
    );
  }
}

class _SearchEntryView extends StatefulWidget {
  const _SearchEntryView();

  @override
  State<_SearchEntryView> createState() => _SearchEntryViewState();
}

class _SearchEntryViewState extends State<_SearchEntryView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(BuildContext context, String query) {
    context.read<SearchBloc>().add(SearchSubmitted(query));
  }

  void _goToResults(BuildContext context, String query) {
    context.push(SearchRoutes.resultsPathForQuery(query));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SearchBloc, SearchState>(
      listenWhen: (previous, current) => current is SearchNavigateToResults,
      listener: (context, state) {
        if (state is SearchNavigateToResults) {
          _goToResults(context, state.query);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Search')),
        body: BlocBuilder<SearchBloc, SearchState>(
          builder: (context, state) {
            return switch (state) {
              SearchInitial() => const Center(child: AppLoadingIndicator()),
              SearchEntryError(:final message) => AppErrorState(
                title: 'Could not open search',
                message: message,
                onRetry: () =>
                    context.read<SearchBloc>().add(const SearchRetried()),
              ),
              SearchNavigateToResults() => const SizedBox.shrink(),
              SearchEntryLoaded() => _buildLoaded(context, state),
            };
          },
        ),
      ),
    );
  }

  Widget _buildLoaded(BuildContext context, SearchEntryLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: AppSearchBar(
            controller: _controller,
            hintText: 'Search products',
            autofocus: true,
            onChanged: (value) =>
                context.read<SearchBloc>().add(SearchQueryChanged(value)),
            onSubmitted: (value) => _submit(context, value),
          ),
        ),
        Expanded(
          child: state.showSuggestions
              ? _SuggestionsBody(
                  state: state,
                  onSuggestionTap: (suggestion) {
                    _controller.text = suggestion.submitText;
                    _controller.selection = TextSelection.collapsed(
                      offset: _controller.text.length,
                    );
                    _submit(context, suggestion.submitText);
                  },
                )
              : _IdleBody(
                  state: state,
                  onTermTap: (term) {
                    _controller.text = term;
                    _controller.selection = TextSelection.collapsed(
                      offset: term.length,
                    );
                    _submit(context, term);
                  },
                  onClearRecent: () => context.read<SearchBloc>().add(
                    const SearchRecentCleared(),
                  ),
                ),
        ),
      ],
    );
  }
}

class _IdleBody extends StatelessWidget {
  const _IdleBody({
    required this.state,
    required this.onTermTap,
    required this.onClearRecent,
  });

  final SearchEntryLoaded state;
  final ValueChanged<String> onTermTap;
  final VoidCallback onClearRecent;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        if (state.recentSearches.isNotEmpty) ...[
          Row(
            children: [
              Expanded(
                child: Text('Recent searches', style: textTheme.titleSmall),
              ),
              TextButton(onPressed: onClearRecent, child: const Text('Clear')),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final term in state.recentSearches)
                AppRecentSearchChip(label: term, onTap: () => onTermTap(term)),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        Text('Trending', style: textTheme.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final term in state.trendingTerms)
              AppRecentSearchChip(label: term, onTap: () => onTermTap(term)),
          ],
        ),
        if (state.recentSearches.isEmpty) ...[
          const SizedBox(height: AppSpacing.xl),
          const AppEmptyState(
            title: 'Find something you love',
            message: 'Try a trending term above, or type to see suggestions.',
          ),
        ],
      ],
    );
  }
}

class _SuggestionsBody extends StatelessWidget {
  const _SuggestionsBody({required this.state, required this.onSuggestionTap});

  final SearchEntryLoaded state;
  final ValueChanged<SearchSuggestion> onSuggestionTap;

  @override
  Widget build(BuildContext context) {
    if (state.isSuggesting && state.suggestions.isEmpty) {
      return const Center(child: AppLoadingIndicator());
    }
    if (state.suggestionsError != null && state.suggestions.isEmpty) {
      return AppInlineErrorBanner(message: state.suggestionsError!);
    }
    if (state.suggestions.isEmpty) {
      return AppEmptyState(
        title: 'No suggestions',
        message: 'Press search to look for “${state.query.trim()}”.',
      );
    }
    return ListView.builder(
      itemCount: state.suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = state.suggestions[index];
        return AppSearchSuggestionTile(
          title: suggestion.title,
          subtitle: suggestion.subtitle,
          kind: switch (suggestion.kind) {
            SearchSuggestionKind.product => AppSearchSuggestionKind.product,
            SearchSuggestionKind.category => AppSearchSuggestionKind.category,
            SearchSuggestionKind.queryCompletion =>
              AppSearchSuggestionKind.queryCompletion,
          },
          onTap: () => onSuggestionTap(suggestion),
        );
      },
    );
  }
}
