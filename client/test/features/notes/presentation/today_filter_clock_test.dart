// F-02: the Today filter read `DateTime.now()` directly, bypassing the
// `currentDateProvider` seam the calendar goldens already use.
//
// The second test is the one that matters. It injects a clock that differs from
// the real current day and asserts that a note due on the *real* current day is
// excluded. A filter that quietly fell back to the wall clock would pass the
// first test and fail this one.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ink/core/domain/result.dart';
import 'package:ink/core/domain/sync_status.dart';
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
import 'package:mocktail/mocktail.dart';

class _Svc extends Mock implements NotesService {}

class _TodaySelected extends SelectedNotebookId {
  @override
  String build() => todayNotebookId;
}

/// A date no test should collide with by accident: it is in the past and is
/// not the day the suite happens to run.
final _injected = DateTime(2026, 1, 14);

Note _note(String id, {DateTime? dueDate, String? notebookId = 'p1'}) => Note(
  id: id,
  title: id,
  content: [
    {'insert': '$id\n'},
  ],
  localVersion: 1,
  lastSyncedVersion: 1,
  syncStatus: SyncStatus.synced,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
  notebookId: notebookId,
  dueDate: dueDate,
  priority: TaskPriority.medium,
);

void main() {
  late _Svc svc;

  setUpAll(() {
    registerFallbackValue(_note('fallback'));
  });

  setUp(() {
    svc = _Svc();
  });

  Future<List<Note>> todayNotes(List<Note> notes, DateTime clock) async {
    // Pin the lens explicitly. These tests are about the Today filter, so they
    // must not depend on which lens happens to be the default; when All notes
    // became the landing view (D-10) the default moved out from under them and
    // the guard below caught it.
    when(
      svc.getAllNotes,
    ).thenAnswer((_) async => Success<List<Note>, NotesFailure>(notes));
    when(
      svc.getAllNotebooks,
    ).thenAnswer((_) async => const Success<List<Notebook>, NotesFailure>([]));

    final container = ProviderContainer(
      overrides: [
        notesServiceProvider.overrideWithValue(svc),
        currentDateProvider.overrideWithValue(clock),
        selectedNotebookIdProvider.overrideWith(_TodaySelected.new),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(selectedNotebookIdProvider), todayNotebookId);

    // `notesProvider` is async and `notebookNotesProvider` derives from it, so
    // settle the load first rather than reading a provider off a cold graph.
    await container.read(notesProvider.future);
    return container.read(notebookNotesProvider);
  }

  test('a note due on the injected day is today', () async {
    final notes = await todayNotes([
      _note('due-today', dueDate: _injected),
    ], _injected);

    expect(notes.map((n) => n.id), ['due-today']);
  });

  test('the wall clock is not consulted', () async {
    // A note due on the real current day must be excluded, because the
    // injected clock says a different day is today.
    final realToday = DateTime.now();

    final notes = await todayNotes([
      _note('due-real-today', dueDate: realToday),
      _note('due-injected', dueDate: _injected),
    ], _injected);

    expect(notes.map((n) => n.id), ['due-injected']);
    expect(notes.map((n) => n.id), isNot(contains('due-real-today')));
  });

  test('notes due on a neighbouring day are excluded', () async {
    final notes = await todayNotes([
      _note('yesterday', dueDate: _injected.subtract(const Duration(days: 1))),
      _note('tomorrow', dueDate: _injected.add(const Duration(days: 1))),
      _note('same', dueDate: _injected),
    ], _injected);

    expect(notes.map((n) => n.id), ['same']);
  });

  test('a note with no due date is never in today', () async {
    final notes = await todayNotes([_note('undated')], _injected);

    expect(notes, isEmpty);
  });

  test('the filter is reproducible whatever day the suite runs', () async {
    // Run the same query at two injected clocks and confirm the result tracks
    // the clock, not the machine's date. This is the property the Home golden
    // depended on and never had.
    final atInjected = await todayNotes([
      _note('n', dueDate: _injected),
    ], _injected);
    final atOther = await todayNotes([
      _note('n', dueDate: _injected),
    ], DateTime(2031, 7, 3));

    expect(atInjected, hasLength(1));
    expect(atOther, isEmpty);
  });
}
