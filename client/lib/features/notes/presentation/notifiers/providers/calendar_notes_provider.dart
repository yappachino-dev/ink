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
  final selectedNotebookId = ref.watch(selectedProjectIdProvider);
  final selectedDate = ref.watch(calendarSelectedDateProvider);

  return allNotes.values.where((note) {
    final writtenOnDay = isSameDay(note.createdAt, selectedDate);
    final matchesNotebook = selectedNotebookId == allProjectsId ||
        selectedNotebookId == note.projectId;

    return writtenOnDay && matchesNotebook;
  }).toList();
}

/// Days in the visible range that hold at least one entry.
///
/// Precomputed per range rather than filtering the whole note set for each
/// cell the grid paints, which `TableCalendar` asks for on every visible day.
@riverpod
Map<DateTime, int> journalEntryCounts(Ref ref) {
  final allNotes = ref.watch(notesProvider).value ?? {};
  final selectedNotebookId = ref.watch(selectedProjectIdProvider);

  final counts = <DateTime, int>{};

  for (final note in allNotes.values) {
    final matchesNotebook =
        selectedNotebookId == allProjectsId ||
        selectedNotebookId == note.projectId;
    if (!matchesNotebook) continue;

    final day = DateTime(
      note.createdAt.year,
      note.createdAt.month,
      note.createdAt.day,
    );

    counts[day] = (counts[day] ?? 0) + 1;
  }

  return counts;
}
