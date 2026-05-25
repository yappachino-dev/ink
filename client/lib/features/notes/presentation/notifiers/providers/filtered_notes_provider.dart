import 'package:ink/features/notes/domain/constants.dart';
import 'package:ink/features/notes/domain/entities/note.dart';
import 'package:ink/features/notes/presentation/notifiers/notes_notifier.dart';
import 'package:ink/features/notes/presentation/notifiers/ui_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'filtered_notes_provider.g.dart';

@riverpod
List<Note> projectNotes(Ref ref) {
  final allNotes = ref.watch(notesProvider).value ?? {};
  final selectedProjectId = ref.watch(selectedProjectIdProvider);

  if (selectedProjectId == todayProjectId) {
    final now = DateTime.now();
    return allNotes.values.where((note) {
      if (note.dueDate == null) return false;

      return note.dueDate!.year == now.year &&
          note.dueDate!.month == now.month &&
          note.dueDate!.day == now.day;
    }).toList();
  }

  if (selectedProjectId == inboxProjectId) {
    return allNotes.values
        .where((note) => note.dueDate != null || note.dueTime != null)
        .toList();
  }

  return allNotes.values
      .where((note) => note.projectId == selectedProjectId)
      .toList();
}
