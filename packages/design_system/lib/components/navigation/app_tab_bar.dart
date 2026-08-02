import 'package:flutter/material.dart';

/// A secondary in-page tab navigation, per docs/08_COMPONENT_LIBRARY.md §12
/// (`AppTabBar`). Used for category chips, FAQ categories, and Marketing
/// tabs.
///
/// Unlike Flutter's `TabBar`, this doesn't require a `TabController`/
/// `DefaultTabController` - it's a fully controlled widget driven by
/// [currentIndex]/[onTap], matching every other selection component in this
/// library.
///
/// ```dart
/// AppTabBar(tabs: const ['All', 'Open', 'Resolved'], currentIndex: index, onTap: setState);
/// ```
class AppTabBar extends StatelessWidget {
  const AppTabBar({
    required this.tabs,
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final List<String> tabs;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < tabs.length; i++)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(tabs[i]),
                selected: i == currentIndex,
                onSelected: (_) => onTap(i),
                selectedColor: colorScheme.primaryContainer,
              ),
            ),
        ],
      ),
    );
  }
}
