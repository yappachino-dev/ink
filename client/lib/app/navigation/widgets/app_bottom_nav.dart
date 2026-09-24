import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/theme/tokens.dart';
import 'package:ink/i18n/strings.g.dart';

/// Application-level navigation shell shared by the main feature screens.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    required this.onDestinationSelected,
    super.key,
  });

  final ValueChanged<int> onDestinationSelected;

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    if (location.startsWith('/notes/calendar')) return 1;
    if (location.startsWith('/profile')) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _calculateSelectedIndex(context);

    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceDim,
        borderRadius: AppRadius.sheetTop,
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          if (index == currentIndex) return;
          onDestinationSelected(index);
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedItemColor: context.colorScheme.primary,
        unselectedItemColor: context.colorScheme.onSurface,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.check_box_outlined),
            label: context.t.note.title,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_month_outlined),
            label: context.t.calendar.title,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            label: context.t.profile.title,
          ),
        ],
      ),
    );
  }
}
