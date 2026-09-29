// D-10: All notes is the default landing view.
//
// Three things are being pinned here, and the third is the one that matters
// most:
//
//  1. The app opens on All notes, and that lens returns every note rather than
//     nothing. Before this, `allNotebooksId` was only meaningful to the
//     calendar's notebook filter, so selecting it on Home fell through to
//     `note.notebookId == '__all__'` and matched nothing.
//  2. It is ordered reverse-chronologically and deterministically, because
//     `allNotes` is a Map and its iteration order is insertion order.
//  3. It renders flat: no completion checkbox, no separate completed section.
//     That is the part that distinguishes a notes list from a task list, and it
//     is the part a title-only change would have missed.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ink/core/config/user_config.dart';
import 'package:ink/core/domain/result.dart';
import 'package:ink/core/domain/sync_status.dart';
import 'package:ink/core/presentation/theme/app_theme.dart';
import 'package:ink/core/presentation/theme/palettes.dart';
import 'package:ink/features/notes/domain/constants.dart';
import 'package:ink/features/notes/domain/entities/note.dart';
import 'package:ink/features/notes/domain/entities/notebook.dart';
import 'package:ink/features/notes/domain/failures/notes_failure.dart';
import 'package:ink/features/notes/domain/notes_providers.dart';
import 'package:ink/features/notes/domain/notes_service.dart';
import 'package:ink/features/notes/domain/task_priority.dart';
import 'package:ink/features/notes/presentation/notifiers/notes_notifier.dart';
import 'package:ink/features/notes/presentation/notifiers/providers/filtered_notes_provider.dart';
import 'package:ink/features/notes/presentation/notifiers/ui_state.dart';
import 'package:ink/features/notes/presentation/widgets/notes/card/note_card.dart';
import 'package:ink/features/notes/presentation/widgets/notes/notes_list.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';

import 'package:mocktail/mocktail.dart';

import '../../../helpers/test_helpers.dart';

class _Svc extends Mock implements NotesService {}

/// A fixed clock, so the Today case never depends on the day the suite runs.
final _today = DateTime(2026, 1, 14);

class _LensSelected extends SelectedNotebookId {
  _LensSelected(this.id);

  final String id;

  @override
  String build() => id;
}

Note _note(
  String id, {
  String? notebookId = 'p1',
  DateTime? dueDate,
  DateTime? updatedAt,
  bool isCompleted = false,
}) => Note(
  id: id,
  title: 'title of $id',
  content: [
    {'insert': 'body of $id\n'},
  ],
  localVersion: 1,
  lastSyncedVersion: 1,
  syncStatus: SyncStatus.synced,
  createdAt: DateTime(2026),
  updatedAt: updatedAt ?? DateTime(2026),
  notebookId: notebookId,
  dueDate: dueDate,
  isCompleted: isCompleted,
  priority: TaskPriority.medium,
);

void main() {
  setUpAll(() {
    registerFallbackValue(_note('fallback'));
  });

  late _Svc svc;

  setUp(() {
    svc = _Svc();
    when(
      svc.getAllNotebooks,
    ).thenAnswer((_) async => const Success<List<Notebook>, NotesFailure>([]));
  });

  Future<ProviderContainer> makeContainer(
    List<Note> notes, {
    String? lens,
  }) async {
    when(
      svc.getAllNotes,
    ).thenAnswer((_) async => Success<List<Note>, NotesFailure>(notes));

    final container = ProviderContainer(
      overrides: [
        notesServiceProvider.overrideWithValue(svc),
        userPreferencesProvider.overrideWithValue(await mockUserConfig()),
        currentDateProvider.overrideWithValue(_today),
        if (lens != null)
          selectedNotebookIdProvider.overrideWith(() => _LensSelected(lens)),
      ],
    );
    addTearDown(container.dispose);
    await container.read(notesProvider.future);
    return container;
  }

  group('the landing view', () {
    test('is All notes, not Today', () async {
      final container = await makeContainer([_note('a')]);

      expect(container.read(selectedNotebookIdProvider), allNotebooksId);
      expect(
        isContentForwardLens(container.read(selectedNotebookIdProvider)),
        isTrue,
      );
    });

    test('is titled "All notes" rather than borrowing "Today"', () async {
      final container = await makeContainer([_note('a')]);

      // Previously both `allNotebooksId` and `todayNotebookId` mapped to
      // `t.home.today`, so two different views were indistinguishable by
      // title and the default view called itself the wrong thing.
      expect(container.read(selectedNotebookTitleProvider), t.home.all);
      expect(
        container.read(selectedNotebookTitleProvider),
        isNot(t.home.today),
      );
    });
  });

  group('the All notes lens', () {
    test('returns every note, whatever its notebook or due date', () async {
      final container = await makeContainer([
        _note('undated-unfiled', notebookId: null),
        _note('dated', notebookId: 'p2', dueDate: DateTime(2030, 5, 5)),
        _note('other-notebook', notebookId: 'p9'),
        _note('completed', isCompleted: true),
      ]);

      final ids = container
          .read(notebookNotesProvider)
          .map((n) => n.id)
          .toSet();

      // The regression this guards: All notes used to fall through to
      // `notebookId == '__all__'` and return nothing at all.
      expect(ids, {'undated-unfiled', 'dated', 'other-notebook', 'completed'});
    });

    test('orders reverse-chronologically by last touch', () async {
      final container = await makeContainer([
        _note('oldest', updatedAt: DateTime(2026)),
        _note('newest', updatedAt: DateTime(2026, 3)),
        _note('middle', updatedAt: DateTime(2026, 2)),
      ]);

      expect(container.read(notebookNotesProvider).map((n) => n.id), [
        'newest',
        'middle',
        'oldest',
      ]);
    });

    test('breaks ties deterministically', () async {
      // Same `updatedAt` and `createdAt`. Map insertion order is the only other
      // thing that could decide this, and it is not stable across a sync.
      final at = DateTime(2026, 5, 5, 12);
      final container = await makeContainer([
        _note('b', updatedAt: at),
        _note('a', updatedAt: at),
        _note('c', updatedAt: at),
      ]);

      expect(container.read(notebookNotesProvider).map((n) => n.id), [
        'a',
        'b',
        'c',
      ]);
    });

    testWidgets('renders flat: no checkbox, no completed section', (
      tester,
    ) async {
      final container = await makeContainer([
        _note('open-note'),
        _note('done-note', isCompleted: true),
      ]);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: TranslationProvider(
            child: MaterialApp(
              theme: AppTheme.light(InkPalette.forest),
              home: const Scaffold(body: NotesList(title: 'All notes')),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Both notes are present, in the one flat list.
      expect(find.byType(NoteCard), findsNWidgets(2));
      expect(find.text('title of open-note'), findsOneWidget);
      expect(find.text('title of done-note'), findsOneWidget);

      // The task affordance is gone. A note may still contain a checklist; the
      // row just stops volunteering completion state it was not asked for.
      expect(find.byType(Checkbox), findsNothing);
      expect(find.text(t.home.completed), findsNothing);
    });
  });

  group('task-forward lenses are unchanged', () {
    test('Today still filters by the injected clock', () async {
      final container = await makeContainer([
        _note('due', dueDate: DateTime(2026, 1, 14)),
        _note('not-due', dueDate: DateTime(2026, 6)),
        _note('undated'),
      ], lens: todayNotebookId);

      final notes = container.read(notebookNotesProvider);
      expect(notes.map((n) => n.id), ['due']);
    });

    test('a notebook still filters to its own notes', () async {
      final container = await makeContainer([
        _note('mine'),
        _note('theirs', notebookId: 'p2'),
        _note('unfiled', notebookId: null),
      ], lens: 'p1');

      expect(container.read(notebookNotesProvider).map((n) => n.id), ['mine']);
    });

    testWidgets('a task-forward lens keeps the completion checkbox', (
      tester,
    ) async {
      // Dated today, or the Today lens would correctly filter it away and the
      // assertion would pass for the wrong reason.
      final container = await makeContainer([
        _note('open-note', dueDate: _today),
      ], lens: todayNotebookId);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: TranslationProvider(
            child: MaterialApp(
              theme: AppTheme.light(InkPalette.forest),
              home: const Scaffold(body: NotesList(title: 'Today')),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Checkbox), findsOneWidget);
    });
  });
}
