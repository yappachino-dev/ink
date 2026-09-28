import 'package:flutter/material.dart' show DateUtils;
import 'package:ink/features/notes/domain/constants.dart';
import 'package:ink/features/notes/domain/entities/note.dart';
import 'package:ink/features/notes/presentation/notifiers/notes_notifier.dart';
import 'package:ink/features/notes/presentation/notifiers/ui_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:table_calendar/table_calendar.dart';

part 'calendar_notes_provider.g.dart';

/// The notes written on the selected calendar day.
///
/// The calendar is a journal: it answers "what did I write on this day", so it
/// keys on `createdAt`. It deliberately does not key on `dueDate`: the due-date
/// axis belongs to the Today and Overdue views, and marking a day for both
/// would make one dot ambiguous between "written here" and "due here".
///
/// Back-dating is not supported yet. A note written today lands on today.
/// If that turns out to matter, the key becomes a user-assignable entry-date
/// column rather than a change of approach, which is why the date should be
/// readable as a column and not hardcoded to the entity.
@riverpod
List<Note> calendarNotes(Ref ref) {
  final allNotes = ref.watch(notesProvider).value ?? {};
  final selectedNotebookId = ref.watch(selectedNotebookIdProvider);
  final selectedDate = ref.watch(calendarSelectedDateProvider);

  return allNotes.values.where((note) {
      final writtenOnDay = isSameDay(note.createdAt, selectedDate);
      final matchesNotebook =
          selectedNotebookId == allNotebooksId ||
          selectedNotebookId == note.notebookId;

      return writtenOnDay && matchesNotebook;
    }).toList()
    // `allNotes` is a Map, so iteration order follows insertion, not time. A
    // journal that reshuffles when an unrelated note syncs is not a journal.
    // Ascending reads as a diary; id breaks ties so two notes written in the
    // same millisecond keep a stable relative order.
    ..sort((a, b) {
      final byTime = a.createdAt.compareTo(b.createdAt);
      return byTime != 0 ? byTime : a.id.compareTo(b.id);
    });
}

/// Days in the visible range that hold at least one entry.
///
/// Precomputed per range rather than filtering the whole note set for each
/// cell the grid paints, which `TableCalendar` asks for on every visible day.
///
/// Keys are `DateUtils.dateOnly` of the stored timestamp, which reads the
/// recorded year/month/day and returns local midnight. `DateTime.==` compares
/// the instant *and* the `isUtc` flag, so a raw lookup would miss whenever the
/// two sides disagreed on either. Normalizing both sides to a local midnight
/// makes the comparison exact.
///
/// Deliberately **not** `.toLocal()`. Converting to the device zone first would
/// re-date an entry whenever the stored time sits near midnight, so the same
/// note would land on different days on different devices, and would move days
/// if the user travelled. A journal records the day as written.
@riverpod
Map<DateTime, int> journalEntryCounts(Ref ref) {
  final allNotes = ref.watch(notesProvider).value ?? {};
  final selectedNotebookId = ref.watch(selectedNotebookIdProvider);

  final counts = <DateTime, int>{};

  for (final note in allNotes.values) {
    final matchesNotebook =
        selectedNotebookId == allNotebooksId ||
        selectedNotebookId == note.notebookId;
    if (!matchesNotebook) continue;

    final day = DateUtils.dateOnly(note.createdAt);

    counts[day] = (counts[day] ?? 0) + 1;
  }

  return counts;
}
