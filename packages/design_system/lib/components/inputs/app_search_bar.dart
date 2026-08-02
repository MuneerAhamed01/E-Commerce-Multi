import 'dart:async';

import 'package:flutter/material.dart';

import '../../tokens/app_radii.dart';
import '../../tokens/app_spacing.dart';

/// Where an [AppSearchBar] is rendered, per docs/08_COMPONENT_LIBRARY.md §5.
enum AppSearchBarVariant {
  /// A free-standing search field (search entry screens).
  standalone,

  /// Embedded within an [AppTopBar] (`AppTopBarVariant.withSearch`).
  shellEmbedded,
}

/// A debounced query input with a clear affordance, per
/// docs/08_COMPONENT_LIBRARY.md §5 (`SearchBar`, renamed `AppSearchBar` here
/// to disambiguate from Flutter's own `SearchBar` widget - see
/// docs/02_PROJECT_STRUCTURE.md §10).
///
/// [onChanged] fires [debounce] after the user stops typing (not on every
/// keystroke), which is the debounced-search-input rule for the Search
/// feature (docs/03_DEVELOPMENT_PHASES.md Phase 11 review checklist);
/// [onSubmitted] always fires immediately on explicit submission.
///
/// ```dart
/// AppSearchBar(
///   hintText: 'Search products',
///   onChanged: (query) => bloc.add(SearchQueryChanged(query)),
///   onSubmitted: (query) => bloc.add(SearchSubmitted(query)),
/// );
/// ```
class AppSearchBar extends StatefulWidget {
  const AppSearchBar({
    this.controller,
    this.hintText = 'Search',
    this.onChanged,
    this.onSubmitted,
    this.variant = AppSearchBarVariant.standalone,
    this.debounce = const Duration(milliseconds: 350),
    this.autofocus = false,
    super.key,
  });

  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final AppSearchBarVariant variant;
  final Duration debounce;
  final bool autofocus;

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  late final TextEditingController _controller;
  bool _ownsController = false;
  Timer? _debounceTimer;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController();
      _ownsController = true;
    }
    _hasText = _controller.text.isNotEmpty;
    _controller.addListener(_handleTextChanged);
  }

  void _handleTextChanged() {
    if (mounted) {
      setState(() => _hasText = _controller.text.isNotEmpty);
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.removeListener(_handleTextChanged);
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value) {
    _debounceTimer?.cancel();
    final onChanged = widget.onChanged;
    if (onChanged == null) {
      return;
    }
    _debounceTimer = Timer(widget.debounce, () => onChanged(value));
  }

  void _clear() {
    _controller.clear();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isEmbedded = widget.variant == AppSearchBarVariant.shellEmbedded;

    return TextField(
      controller: _controller,
      autofocus: widget.autofocus,
      onChanged: _onChanged,
      onSubmitted: widget.onSubmitted,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _hasText
            ? IconButton(
                icon: const Icon(Icons.clear),
                tooltip: 'Clear search',
                onPressed: _clear,
              )
            : null,
        filled: true,
        fillColor: isEmbedded
            ? colorScheme.surfaceContainerHighest
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        border: const OutlineInputBorder(
          borderRadius: AppRadii.borderRadiusFull,
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadii.borderRadiusFull,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.borderRadiusFull,
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
      ),
    );
  }
}
