import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ink/app/navigation/widgets/app_bottom_nav.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/features/notes/domain/constants.dart';
import 'package:ink/features/notes/presentation/notifiers/ui_state.dart';
import 'package:material_ui/material_ui.dart';

/// Hosts the navigation branches and owns the single navigation bar (F-10).
///
/// Each branch keeps its own [Navigator] inside an [IndexedStack], so leaving a
/// tab and coming back restores its scroll position, its open sheets and its
/// local state. Previously every tab switch was a `context.go()` against a flat
/// route list, which rebuilt the screen from scratch each time.
class AppShell extends ConsumerWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: context.ink.surface,
      body: navigationShell,
      bottomNavigationBar: AppBottomNav(
        currentIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => _select(ref, index),
      ),
    );
  }

  void _select(WidgetRef ref, int index) {
    // Home and Calendar read the same lens. Leaving a task lens like "Today"
    // and landing on the journal would filter it by a pseudo-notebook that
    // exists in neither, so entering Calendar returns the shared selection to
    // "everything". The reset used to live in each screen's tab handler, which
    // the shell removed; the coupling itself predates it.
    if (index == _calendarBranch) {
      ref.read(selectedProjectIdProvider.notifier).id = allProjectsId;
    }

    navigationShell.goBranch(
      index,
      // Tapping the active tab returns it to its root, which is what a tab is
      // expected to do; every other switch preserves the branch's state.
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  /// Index of the Calendar branch, kept next to the reset that depends on it.
  static const _calendarBranch = 1;
}
