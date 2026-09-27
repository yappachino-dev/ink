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
    // The injected clock, not the wall clock. `currentDateProvider` is the seam
    // the calendar goldens already rely on; the Today filter was the one view
    // that read `DateTime.now()` directly, which made it untestable and left
    // the Home golden rendering an empty list whenever the fixture's due date
    // did not happen to match the day the suite ran.
    final now = ref.watch(currentDateProvider);
    return allNotes.values.where((note) {
      if (note.dueDate == null) return false;

      return note.dueDate!.year == now.year &&
          note.dueDate!.month == now.month &&
          note.dueDate!.day == now.day;
    }).toList();
  }

  return allNotes.values
      .where((note) => note.projectId == selectedProjectId)
      .toList();
}
