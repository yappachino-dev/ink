import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ink/core/domain/result.dart';
import 'package:ink/core/domain/sync_status.dart';
import 'package:ink/features/notes/domain/constants.dart';
import 'package:ink/features/notes/domain/entities/note.dart';
import 'package:ink/features/notes/domain/entities/project.dart';
import 'package:ink/features/notes/domain/failures/notes_failure.dart';
import 'package:ink/features/notes/domain/notes_providers.dart';
import 'package:ink/features/notes/domain/notes_service.dart';
import 'package:ink/features/notes/presentation/notifiers/notes_notifier.dart';
import 'package:ink/features/notes/presentation/notifiers/providers/calendar_notes_provider.dart';
import 'package:ink/features/notes/presentation/notifiers/ui_state.dart';
import 'package:mocktail/mocktail.dart';

class _Svc extends Mock implements NotesService {}

final _selectedDay = DateTime(2026, 3, 14);

Note _note({
  required String id,
  required DateTime createdAt,
  DateTime? dueDate,
  String? projectId,
  bool isCompleted = false,
}) => Note(
  id: id,
  title: 'Note $id',
  content: const [
    {'insert': 'Body\n'},
  ],
  localVersion: 1,
  lastSyncedVersion: 1,
  syncStatus: SyncStatus.synced,
  createdAt: createdAt,
  updatedAt: createdAt,
  dueDate: dueDate,
  projectId: projectId,
  isCompleted: isCompleted,
);

void main() {
  /// Drives the real notifiers: `calendarSelectedDateProvider` is seeded from
  /// [currentDateProvider], and the notebook selection is set through its
  /// notifier, so the providers under test are the production ones.
  Future<ProviderContainer> containerWith(
    List<Note> notes, {
    String? selectedProjectId,
  }) async {
    final notebook = selectedProjectId ?? allProjectsId;
    final svc = _Svc();
    when(svc.getAllNotes).thenAnswer(
      (_) async => Success<List<Note>, NotesFailure>(notes),
    );
    when(svc.getAllProjects).thenAnswer(
      (_) async => const Success<List<Project>, NotesFailure>([]),
    );

    final container = ProviderContainer(
      overrides: [
        notesServiceProvider.overrideWithValue(svc),
        currentDateProvider.overrideWithValue(_selectedDay),
      ],
    );
    addTearDown(container.dispose);

    await container.read(notesProvider.future);
    container.read(selectedProjectIdProvider.notifier).id = notebook;
    await container.read(notesProvider.future);

    return container;
  }

  group('calendarNotes is a journal of written days', () {
    test('keys on createdAt rather than dueDate', () async {
      final container = await containerWith([
        _note(id: 'written-today', createdAt: _selectedDay),
        // Due on the selected day but written on another: must not appear.
        _note(
          id: 'due-only',
          createdAt: DateTime(2026, 3),
          dueDate: _selectedDay,
        ),
        // Written on the selected day but due later: must appear.
        _note(
          id: 'written-and-due-later',
          createdAt: _selectedDay,
          dueDate: DateTime(2026, 4),
        ),
      ]);

      final ids = container
          .read(calendarNotesProvider)
          .map((n) => n.id)
          .toSet();

      expect(ids, {'written-today', 'written-and-due-later'});
      expect(ids, isNot(contains('due-only')));
    });

    test(
      'includes completed notes: a journal records what was written',
      () async {
      final container = await containerWith([
        _note(id: 'done', createdAt: _selectedDay, isCompleted: true),
      ]);

      expect(container.read(calendarNotesProvider).single.id, 'done');
    });

    test('ignores the time of day when matching a day', () async {
      final container = await containerWith([
        _note(id: 'late', createdAt: DateTime(2026, 3, 14, 23, 59)),
      ]);

      expect(container.read(calendarNotesProvider).single.id, 'late');
    });

    test('still respects the selected notebook', () async {
      final container = await containerWith(
        [
          _note(id: 'in-a', createdAt: _selectedDay, projectId: 'a'),
          _note(id: 'in-b', createdAt: _selectedDay, projectId: 'b'),
        ],
        selectedProjectId: 'a',
      );

      expect(container.read(calendarNotesProvider).single.id, 'in-a');
    });
  });

  group('journalEntryCounts', () {
    test('counts every entry written on a day', () async {
      final container = await containerWith([
        _note(id: 'a', createdAt: DateTime(2026, 3, 14, 9)),
        _note(id: 'b', createdAt: DateTime(2026, 3, 14, 18)),
        _note(id: 'c', createdAt: DateTime(2026, 3, 15, 9)),
      ]);

      final counts = container.read(journalEntryCountsProvider);

      expect(counts[DateTime(2026, 3, 14)], 2);
      expect(counts[DateTime(2026, 3, 15)], 1);
    });

    test(
      'counts a note on the day it was written, not the day it is due',
      () async {
      final container = await containerWith([
        _note(
          id: 'due-only',
          createdAt: DateTime(2026, 3),
          dueDate: _selectedDay,
        ),
      ]);

      final counts = container.read(journalEntryCountsProvider);

      expect(counts[DateTime(2026, 3)], 1);
      expect(counts[_selectedDay], isNull);
    });
  });
}
