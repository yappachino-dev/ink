// Notes and Calendar each built their own floating action button, and the two
// disagreed: Notes placed its by hand, 20px from the edge, while Calendar used
// the Scaffold's slot, which hard-codes a 16px margin. Switching tabs therefore
// moved the button 4px, and the elevations differed too (0 against 4), so it
// read as a glitch rather than a change of screen.
//
// Both now come from AppFab, placed by AppFabLocation off AppSpacing.fabInset.
// This asserts the two land on the same pixels.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:ink/app/navigation/widgets/app_shell.dart';
import 'package:ink/core/domain/result.dart';
import 'package:ink/core/domain/sync_status.dart';
import 'package:ink/core/infrastructure/storage/shared_prefs.dart';
import 'package:ink/core/presentation/navigation/app_destinations.dart';
import 'package:ink/core/presentation/providers/status_providers.dart';
import 'package:ink/core/presentation/theme/app_theme.dart';
import 'package:ink/core/presentation/theme/palettes.dart';
import 'package:ink/core/presentation/theme/tokens.dart';
import 'package:ink/core/presentation/widgets/app_fab.dart';
import 'package:ink/features/notes/domain/constants.dart';
import 'package:ink/features/notes/domain/entities/note.dart';
import 'package:ink/features/notes/domain/entities/project.dart';
import 'package:ink/features/notes/domain/failures/notes_failure.dart';
import 'package:ink/features/notes/domain/notes_providers.dart';
import 'package:ink/features/notes/domain/notes_service.dart';
import 'package:ink/features/notes/presentation/notifiers/ui_state.dart';
import 'package:ink/features/notes/presentation/screens/calendar_screen.dart';
import 'package:ink/features/notes/presentation/screens/home_screen.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Svc extends Mock implements NotesService {}

class _AllProjectsSelected extends SelectedProjectId {
  @override
  String build() => allProjectsId;
}

final _note = Note(
  id: 'n1',
  title: 'Note',
  content: [
    {'insert': 'Body\n'},
  ],
  localVersion: 1,
  lastSyncedVersion: 1,
  syncStatus: SyncStatus.synced,
  createdAt: DateTime(2026, 1, 14),
  updatedAt: DateTime(2026, 1, 14),
  projectId: allProjectsId,
);

/// The real shell, with both branches built for real, so the two buttons are
/// measured under the navigation bar that actually hosts them.
GoRouter _router(String initial) => GoRouter(
  initialLocation: initial,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (_, _, shell) => AppShell(navigationShell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppDestinations.notes,
              builder: (_, _) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppDestinations.calendar,
              builder: (_, _) => const CalendarScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppDestinations.profile,
              builder: (_, _) => const SizedBox.shrink(),
            ),
          ],
        ),
      ],
    ),
  ],
);

void main() {
  Future<void> open(WidgetTester tester, String branch) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final svc = _Svc();
    when(
      svc.getAllNotes,
    ).thenAnswer((_) async => Success<List<Note>, NotesFailure>([_note]));
    when(
      svc.getAllProjects,
    ).thenAnswer((_) async => const Success<List<Project>, NotesFailure>([]));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notesServiceProvider.overrideWithValue(svc),
          isOfflineProvider.overrideWithValue(false),
          sharedPreferencesProvider.overrideWithValue(prefs),
          selectedProjectIdProvider.overrideWith(_AllProjectsSelected.new),
        ],
        child: TranslationProvider(
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(InkPalette.forest),
            routerConfig: _router(branch),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Notes and Calendar place the button on the same pixels', (
    tester,
  ) async {
    await open(tester, AppDestinations.notes);
    final notes = tester.getRect(find.byType(AppFab));

    await open(tester, AppDestinations.calendar);
    final calendar = tester.getRect(find.byType(AppFab));

    expect(
      calendar,
      notes,
      reason:
          'the button jumped when switching tabs: each screen placed its own '
          'rather than sharing AppFabLocation',
    );
  });

  testWidgets('the button sits one token inset from the trailing edge', (
    tester,
  ) async {
    await open(tester, AppDestinations.notes);
    final fab = tester.getRect(find.byType(AppFab));
    final shell = tester.getRect(find.byType(Scaffold).first);

    // Assert the token, not a literal: changing AppSpacing.fabInset has to
    // move this with everything else.
    expect(shell.right - fab.right, closeTo(AppSpacing.fabInset, 0.5));
  });

  testWidgets('the button clears the navigation bar by the same token', (
    tester,
  ) async {
    await open(tester, AppDestinations.calendar);
    final fab = tester.getRect(find.byType(AppFab));
    final navTop = tester.getRect(find.byType(NavigationBar)).top;

    expect(
      navTop - fab.bottom,
      closeTo(AppSpacing.fabInset, 0.5),
      reason: 'the gap to the navigation bar should be the token too',
    );
  });
}
