import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/features/notes/domain/constants.dart';
import 'package:ink/features/notes/presentation/navigation/notes_routes.dart';
import 'package:ink/features/notes/presentation/notifiers/ui_state.dart';
import 'package:ink/features/profile/presentation/navigation/profile_routes.dart';
import 'package:ink/i18n/strings.g.dart';

class BottomNav extends ConsumerWidget {
  const BottomNav({super.key});

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    if (location.startsWith('/notes/calendar')) return 1;
    if (location.startsWith('/profile')) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = _calculateSelectedIndex(context);

    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceDim,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          if (index == currentIndex) return;

          switch (index) {
            case 0:
              if (ref.read(selectedProjectIdProvider) == allProjectsId) {
                ref
                    .read(selectedProjectIdProvider.notifier)
                    .set(todayProjectId);
              }
              const NotesRoute().go(context);
            case 1:
              ref.read(selectedProjectIdProvider.notifier).set(allProjectsId);
              const NotesCalendarRoute().go(context);
            case 2:
              const ProfileRoute().go(context);
          }
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
