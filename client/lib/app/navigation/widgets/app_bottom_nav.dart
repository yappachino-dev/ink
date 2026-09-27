import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';

/// The application navigation bar.
///
/// Material 3's [NavigationBar] with labels, replacing a Material 2
/// [BottomNavigationBar] that hid them (F-09). Three bare icons in a row
/// required guessing, and the unselected tabs used full text strength so all
/// three carried equal visual weight. [NavigationBar] already applies the
/// muted role to unselected destinations, which is the correction F-09 asked
/// for, so nothing here overrides it.
class AppBottomNav extends ConsumerWidget {
  const AppBottomNav({
    required this.currentIndex,
    required this.onDestinationSelected,
    super.key,
  });

  /// The active branch index, owned by the navigation shell.
  final int currentIndex;

  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;

    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        if (index == currentIndex) return;
        onDestinationSelected(index);
      },
      indicatorColor: context.colorScheme.secondaryContainer,
      destinations: [
        // Not a checkbox: the note-first product has tasks as a contextual
        // capability, not as its identity.
        NavigationDestination(
          icon: const Icon(Icons.description_outlined),
          selectedIcon: const Icon(Icons.description),
          label: t.note.title,
        ),
        NavigationDestination(
          icon: const Icon(Icons.calendar_month_outlined),
          selectedIcon: const Icon(Icons.calendar_month),
          label: t.calendar.title,
        ),
        NavigationDestination(
          icon: const Icon(Icons.person_outline),
          selectedIcon: const Icon(Icons.person),
          label: t.profile.title,
        ),
      ],
    );
  }
}
