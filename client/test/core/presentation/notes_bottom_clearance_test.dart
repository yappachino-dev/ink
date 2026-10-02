import 'package:flutter/services.dart';
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
import 'package:ink/features/notes/domain/entities/note.dart';
import 'package:ink/features/notes/domain/entities/notebook.dart';
import 'package:ink/features/notes/domain/failures/notes_failure.dart';
import 'package:ink/features/notes/domain/notes_lens.dart';
import 'package:ink/features/notes/domain/notes_providers.dart';
import 'package:ink/features/notes/domain/notes_service.dart';
import 'package:ink/features/notes/domain/task_priority.dart';
import 'package:ink/features/notes/presentation/notifiers/ui_state.dart';
import 'package:ink/features/notes/presentation/screens/notes_screen.dart';
import 'package:ink/features/notes/presentation/widgets/notes/card/note_card.dart';
import 'package:ink/features/notes/presentation/widgets/notes/notes_view.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A shell with a full list of notes, scrolled to the end.
///
/// The existing goldens use a single note, so the list never overflows and the
/// bottom of the surface is never exercised. That is how a viewport clipped
/// 24px short of the navigation bar, cutting the last card in half and leaving
/// a band of bare background above the bar, passed every golden in the suite.
class _NotesServiceMock extends Mock implements NotesService {}

Future<Result<List<Note>, NotesFailure>> _allNotes(List<Note> notes) async =>
    Success<List<Note>, NotesFailure>(notes);

Future<Result<List<Notebook>, NotesFailure>> _allNotebooks(
  Invocation _,
) async => const Success<List<Notebook>, NotesFailure>([]);

class _AllNotebooksSelected extends NotesLensSelection {
  @override
  NotesLens build() => const NotesLens.all();
}

List<Note> _manyNotes(int count) => List.generate(
  count,
  (i) => Note(
    id: 'note-$i',
    title: 'Note number ${i + 1}',
    content: [
      {
        'insert':
            'Body text for note ${i + 1}. '
            'Some filler to make the card a realistic height.',
      },
    ],
    localVersion: 1,
    lastSyncedVersion: 1,
    syncStatus: SyncStatus.synced,
    createdAt: DateTime(2026, 1, 14).subtract(Duration(hours: count - i)),
    updatedAt: DateTime(2026, 1, 14),
    dueDate: DateTime(2026, 1, 14, 9 + (i % 8)),
    priority: TaskPriority.medium,
  ),
);

void main() {
  setUpAll(() async {
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });

  testWidgets('the last note is not clipped by the navigation bar', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final service = _NotesServiceMock();
    when(service.getAllNotes).thenAnswer((_) => _allNotes(_manyNotes(14)));
    when(service.getAllNotebooks).thenAnswer(_allNotebooks);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notesServiceProvider.overrideWithValue(service),
          isOfflineProvider.overrideWithValue(false),
          sharedPreferencesProvider.overrideWithValue(prefs),
          notesLensSelectionProvider.overrideWith(_AllNotebooksSelected.new),
        ],
        child: TranslationProvider(
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(InkPalette.forest),
            routerConfig: _router(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Scroll to the very end of the list.
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -3000));
    await tester.pumpAndSettle();

    final navTop = tester.getRect(find.byType(NavigationBar)).top;
    final listBottom = tester.getRect(find.byType(NotesView)).bottom;

    // The scrolling surface has to run all the way to the navigation bar. A
    // bottom inset on the wrapper shrinks the viewport instead of adding
    // scrollable room below the last card, so the list stops short, the last
    // card is cut against the bar, and the leftover strip shows as a band of
    // bare background. Calendar's journal has no such inset and does not have
    // this problem, which is what makes it the reference.
    expect(
      listBottom,
      closeTo(navTop, 0.5),
      reason: 'the notes list must reach the navigation bar with no dead band',
    );

    // And the final note must be genuinely on screen, not merely reachable.
    expect(
      find.text('Note number 1'),
      findsOneWidget,
      reason: 'the list should be scrolled to its end',
    );
  });

  testWidgets('the final notes can scroll clear of the floating button', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final service = _NotesServiceMock();
    when(service.getAllNotes).thenAnswer((_) => _allNotes(_manyNotes(14)));
    when(service.getAllNotebooks).thenAnswer(_allNotebooks);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notesServiceProvider.overrideWithValue(service),
          isOfflineProvider.overrideWithValue(false),
          sharedPreferencesProvider.overrideWithValue(prefs),
          notesLensSelectionProvider.overrideWith(_AllNotebooksSelected.new),
        ],
        child: TranslationProvider(
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(InkPalette.forest),
            routerConfig: _router(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(Scrollable).first, const Offset(0, -3000));
    await tester.pumpAndSettle();

    final fab = tester.getRect(find.byType(FloatingActionButton));

    // The button is Positioned over the list rather than placed in a layout
    // slot, so nothing reserves space for it. The clearance has to live inside
    // the scrollable content - in the ListView's own padding, not around the
    // viewport - or the last cards park underneath the button with their text
    // and tap targets covered.
    for (final label in ['Note number 1', 'Note number 2', 'Note number 3']) {
      final card = tester.getRect(
        find.ancestor(of: find.text(label), matching: find.byType(NoteCard)),
      );
      expect(
        card.bottom,
        lessThanOrEqualTo(fab.top + 0.5),
        reason:
            '"$label" ends at ${card.bottom} but the FAB starts at '
            '${fab.top}, so the button is covering it',
      );
    }
  });
}

GoRouter _router() => GoRouter(
  initialLocation: AppDestinations.notes,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (_, _, shell) => AppShell(navigationShell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppDestinations.notes,
              builder: (_, _) => const NotesScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppDestinations.calendar,
              builder: (_, _) => const SizedBox.shrink(),
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
