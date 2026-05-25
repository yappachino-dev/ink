import 'package:ink/features/notes/domain/constants.dart';
import 'package:ink/features/notes/domain/entities/note.dart';
import 'package:ink/features/notes/presentation/notifiers/notes_notifier.dart';
import 'package:ink/features/notes/presentation/notifiers/ui_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:table_calendar/table_calendar.dart';

part 'calendar_notes_provider.g.dart';

@riverpod
List<Note> calendarNotes(Ref ref) {
  final allNotes = ref.watch(notesProvider).value ?? {};
  final selectedProjectId = ref.watch(selectedProjectIdProvider);
  final selectedDate = ref.watch(calendarSelectedDateProvider);

  return allNotes.values.where((note) {
    final isSameDate = isSameDay(note.dueDate, selectedDate);
    final matchesProject =
        selectedProjectId == allProjectsId ||
        selectedProjectId == note.projectId;

    return isSameDate && matchesProject;
  }).toList();
}

@riverpod
List<Note> activeCalendarNotes(Ref ref) {
  final notes = ref.watch(calendarNotesProvider);

  return notes.where((note) => !note.isCompleted).toList();
}

@riverpod
List<Note> completedCalendarNotes(Ref ref) {
  final notes = ref.watch(calendarNotesProvider);

  return notes.where((note) => note.isCompleted).toList();
}
