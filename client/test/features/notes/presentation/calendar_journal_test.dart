import 'package:flutter/material.dart' show DateUtils;
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

  group('day keys are normalized and timezone-stable', () {
    // `DateTime.==` compares the instant AND the `isUtc` flag, so a raw map
    // lookup misses whenever the two sides disagree on either. Both sides are
    // normalized with `DateUtils.dateOnly`.
    // NOTE: this test discriminates only outside UTC. Under a UTC clock the
    // recorded day and the local day coincide, so both implementations pass.
    // CI and local runs here are not UTC, which is also the normal case for the
    // consumer app this ships to.
    test('a UTC entry is keyed on the day it was recorded, not the local day',
        () async {
      // 23:00 UTC on the 14th. In any zone east of UTC this converts to the
      // 15th, which is exactly the re-dating that must not happen.
      final container = await containerWith([
        _note(
          id: 'late-utc',
          createdAt: DateTime.utc(2026, 3, 14, 23),
        ),
      ]);

      final counts = container.read(journalEntryCountsProvider);

      expect(counts[DateTime(2026, 3, 14)], 1);
      expect(counts[DateTime(2026, 3, 15)], isNull);
    });

    test('keys are local midnight, so an exact lookup succeeds', () async {
      final container = await containerWith([
        _note(id: 'a', createdAt: DateTime.utc(2026, 3, 14, 6)),
      ]);

      final counts = container.read(journalEntryCountsProvider);

      // Mirrors what CalendarCard does for every painted cell.
      expect(counts[DateUtils.dateOnly(DateTime(2026, 3, 14))], 1);
    });

    test('a day carrying a time component still resolves', () async {
      final container = await containerWith([
        _note(id: 'a', createdAt: DateTime(2026, 3, 14, 22, 30)),
      ]);

      final counts = container.read(journalEntryCountsProvider);

      expect(counts[DateUtils.dateOnly(DateTime(2026, 3, 14, 8))], 1);
    });
  });

  group('calendarNotes is chronologically ordered', () {
    test('entries read morning to evening', () async {
      final container = await containerWith([
        _note(id: 'c', createdAt: _selectedDay.add(const Duration(hours: 18))),
        _note(id: 'a', createdAt: _selectedDay.add(const Duration(hours: 7))),
        _note(id: 'b', createdAt: _selectedDay.add(const Duration(hours: 12))),
      ]);

      expect(
        container.read(calendarNotesProvider).map((n) => n.id).toList(),
        ['a', 'b', 'c'],
      );
    });

    test('order is independent of map insertion order', () async {
      final forwards = await containerWith([
        _note(id: 'a', createdAt: _selectedDay.add(const Duration(hours: 7))),
        _note(id: 'b', createdAt: _selectedDay.add(const Duration(hours: 12))),
      ]);
      final backwards = await containerWith([
        _note(id: 'b', createdAt: _selectedDay.add(const Duration(hours: 12))),
        _note(id: 'a', createdAt: _selectedDay.add(const Duration(hours: 7))),
      ]);

      expect(
        forwards.read(calendarNotesProvider).map((n) => n.id).toList(),
        backwards.read(calendarNotesProvider).map((n) => n.id).toList(),
      );
    });

    test('ties break on id so the order is total', () async {
      final sameInstant = _selectedDay.add(const Duration(hours: 9));
      final container = await containerWith([
        _note(id: 'z', createdAt: sameInstant),
        _note(id: 'a', createdAt: sameInstant),
      ]);

      expect(
        container.read(calendarNotesProvider).map((n) => n.id).toList(),
        ['a', 'z'],
      );
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
