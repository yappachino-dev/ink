import 'package:ink/features/notes/domain/constants.dart';
import 'package:ink/features/notes/domain/entities/note.dart';
import 'package:ink/features/notes/presentation/notifiers/notes_notifier.dart';
import 'package:ink/features/notes/presentation/notifiers/ui_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'filtered_notes_provider.g.dart';

@riverpod
List<Note> notebookNotes(Ref ref) {
  final allNotes = ref.watch(notesProvider).value ?? {};
  final selectedNotebookId = ref.watch(selectedNotebookIdProvider);

  if (selectedNotebookId == todayNotebookId) {
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

  if (isContentForwardLens(selectedNotebookId)) {
    // Reverse-chronological by last touch: the note you were last working on
    // belongs at the top, which is what makes this a notes list rather than a
    // diary. `allNotes` is a Map, so iteration order follows insertion and
    // would reshuffle whenever an unrelated note synced. `id` breaks ties so
    // two notes written in the same millisecond keep a stable relative order.
    final all = allNotes.values.toList()
      ..sort((a, b) {
        final byUpdated = b.updatedAt.compareTo(a.updatedAt);
        if (byUpdated != 0) return byUpdated;
        final byCreated = b.createdAt.compareTo(a.createdAt);
        if (byCreated != 0) return byCreated;
        return a.id.compareTo(b.id);
      });
    return all;
  }

  return allNotes.values
      .where((note) => note.notebookId == selectedNotebookId)
      .toList();
}
