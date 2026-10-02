import 'package:ink/features/notes/domain/entities/note.dart';
import 'package:ink/features/notes/domain/notes_lens.dart';
import 'package:ink/features/notes/presentation/notifiers/notes_notifier.dart';
import 'package:ink/features/notes/presentation/notifiers/ui_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'filtered_notes_provider.g.dart';

@riverpod
List<Note> notebookNotes(Ref ref) {
  final allNotes = ref.watch(notesProvider).value ?? {};
  final lens = ref.watch(notesLensSelectionProvider);

  return switch (lens) {
    // The injected clock, not the wall clock. `currentDateProvider` is the seam
    // the calendar goldens already rely on; the Today filter was the one view
    // that read `DateTime.now()` directly, which made it untestable and left
    // the notes golden rendering an empty list whenever the fixture's due date
    // did not match the day the suite ran.
    TodayLens() => _dueToday(ref, allNotes.values),
    // Reverse-chronological by last touch: the note you were last working on
    // belongs at the top, which is what makes this a notes list rather than a
    // diary. `allNotes` is a Map, so iteration order follows insertion and
    // would reshuffle whenever an unrelated note synced. `id` breaks ties so
    // two notes written in the same millisecond keep a stable order.
    AllNotesLens() => _byLastTouched(allNotes.values),
    NotebookLens(:final notebookId) =>
      allNotes.values.where((note) => note.notebookId == notebookId).toList(),
  };
}

List<Note> _dueToday(Ref ref, Iterable<Note> notes) {
  final now = ref.watch(currentDateProvider);

  return notes
      .where(
        (note) =>
            note.dueDate?.year == now.year &&
            note.dueDate?.month == now.month &&
            note.dueDate?.day == now.day,
      )
      .toList();
}

List<Note> _byLastTouched(Iterable<Note> notes) {
  return notes.toList()..sort((a, b) {
    final byUpdated = b.updatedAt.compareTo(a.updatedAt);
    if (byUpdated != 0) return byUpdated;
    final byCreated = b.createdAt.compareTo(a.createdAt);
    if (byCreated != 0) return byCreated;
    return a.id.compareTo(b.id);
  });
}
