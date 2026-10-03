import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ink/core/config/user_config.dart';
import 'package:ink/core/domain/result.dart';
import 'package:ink/core/domain/sync_status.dart';
import 'package:ink/core/presentation/theme/app_theme.dart';
import 'package:ink/core/presentation/theme/palettes.dart';
import 'package:ink/features/notes/domain/entities/note.dart';
import 'package:ink/features/notes/domain/entities/notebook.dart';
import 'package:ink/features/notes/domain/failures/notes_failure.dart';
import 'package:ink/features/notes/domain/notes_lens.dart';
import 'package:ink/features/notes/domain/notes_providers.dart';
import 'package:ink/features/notes/domain/notes_service.dart';
import 'package:ink/features/notes/domain/task_priority.dart';
import 'package:ink/features/notes/presentation/notifiers/notes_notifier.dart';
import 'package:ink/features/notes/presentation/notifiers/ui_state.dart';
import 'package:ink/features/notes/presentation/widgets/calendar/journal_day_list.dart';
import 'package:ink/features/notes/presentation/widgets/notes/card/note_card.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/test_helpers.dart';

class _Svc extends Mock implements NotesService {}

final _day = DateTime(2026, 3, 14);

Note _note({
  required String id,
  String? notebookId,
  bool isCompleted = false,
  TaskPriority priority = TaskPriority.high,
}) => Note(
  id: id,
  title: 'Entry $id',
  // A real Quill document always carries at least one op. An empty list is
  // rejected by Document.fromJson, which the card calls for the description
  // line -- see finding F-24.
  content: const [
    {'insert': 'Body of the entry\n'},
  ],
  localVersion: 1,
  lastSyncedVersion: 1,
  syncStatus: SyncStatus.synced,
  createdAt: _day,
  updatedAt: _day,
  notebookId: notebookId,
  isCompleted: isCompleted,
  priority: priority,
);

void main() {
  Future<void> pumpList(WidgetTester tester, List<Note> notes) async {
    final svc = _Svc();
    when(
      svc.getAllNotes,
    ).thenAnswer((_) async => Success<List<Note>, NotesFailure>(notes));
    when(
      svc.getAllNotebooks,
    ).thenAnswer((_) async => const Success<List<Notebook>, NotesFailure>([]));

    final container = ProviderContainer(
      overrides: [
        notesServiceProvider.overrideWithValue(svc),
        userPreferencesProvider.overrideWithValue(await mockUserConfig()),
        currentDateProvider.overrideWithValue(_day),
      ],
    );
    addTearDown(container.dispose);

    // `notesLensSelectionProvider` defaults to All notes, which is a
    // notebook sentinel and would filter every fixture note out. The calendar
    // shows all notebooks unless the user narrows it.
    await container
        .read(notesLensSelectionProvider.notifier)
        .select(const NotesLens.all());
    await container.read(notesProvider.future);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TranslationProvider(
          child: MaterialApp(
            theme: AppTheme.light(InkPalette.forest),
            home: const Scaffold(body: JournalDayList()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders every entry written that day', (tester) async {
    await pumpList(tester, [_note(id: 'a'), _note(id: 'b')]);

    expect(find.text('Entry a'), findsOneWidget);
    expect(find.text('Entry b'), findsOneWidget);
  });

  testWidgets('shows no completion checkbox: a journal is not a task list', (
    tester,
  ) async {
    await pumpList(tester, [_note(id: 'a')]);

    // The card is present, but with the completion control opted out.
    expect(find.byType(NoteCard), findsOneWidget);
    final card = tester.widget<NoteCard>(find.byType(NoteCard));

    expect(card.showCompletion, isFalse);
    expect(find.byType(Checkbox), findsNothing);
  });

  testWidgets('shows no priority flag', (tester) async {
    await pumpList(tester, [_note(id: 'a')]);

    final card = tester.widget<NoteCard>(find.byType(NoteCard));

    expect(card.showPriority, isFalse);
    expect(find.byIcon(Icons.flag), findsNothing);
  });

  testWidgets('does not partition the day into completed entries', (
    tester,
  ) async {
    await pumpList(tester, [
      _note(id: 'done', isCompleted: true),
      _note(id: 'open'),
    ]);

    // A completed entry is still an entry and is listed alongside the rest.
    expect(find.text('Entry done'), findsOneWidget);
    expect(find.text('Entry open'), findsOneWidget);
  });

  testWidgets('does not strike through a completed entry', (tester) async {
    // The journal reports nothing about completion, so it must not hint at it
    // through typography either. A strikethrough here would reintroduce the
    // task reading the journal dropped everywhere else.
    await pumpList(tester, [_note(id: 'done', isCompleted: true)]);

    final title = tester.widget<Text>(find.text('Entry done'));
    expect(title.style?.decoration, isNot(TextDecoration.lineThrough));
  });

  testWidgets('shows an explicit empty state for a day with no entries', (
    tester,
  ) async {
    await pumpList(tester, []);

    expect(find.text(t.calendar.noNotes), findsOneWidget);
  });

  testWidgets('omits the notebook label for unfiled entries', (tester) async {
    await pumpList(tester, [_note(id: 'a')]);

    final card = tester.widget<NoteCard>(find.byType(NoteCard));

    expect(card.notebookName, isNull);
  });
}
