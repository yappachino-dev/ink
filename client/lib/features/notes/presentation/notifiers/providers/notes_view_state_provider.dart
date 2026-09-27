import 'package:ink/features/notes/presentation/notifiers/notes_notifier.dart';
import 'package:ink/features/notes/presentation/notifiers/providers/filtered_notes_provider.dart';
import 'package:ink/features/notes/presentation/widgets/notes/notes_view_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notes_view_state_provider.g.dart';

@riverpod
NotesViewState notesViewState(Ref ref) {
  final notesAsync = ref.watch(notesProvider);
  final lensNotes = ref.watch(projectNotesProvider);

  // `hasError` is checked before `when` on purpose. A failed load is an
  // `AsyncLoading` that carries an error, so `when(loading: ...)` matches it
  // and the surface would show a skeleton forever instead of the error.
  if (notesAsync.hasError) {
    return NotesViewError(notesAsync.error!);
  }

  return notesAsync.when(
    loading: () => const NotesViewLoading(),
    error: (error, _) => NotesViewError(error),
    data: (allNotes) {
      if (lensNotes.isEmpty) {
        return allNotes.isEmpty
            ? const NotesViewEmpty()
            : const NotesViewEmptyByFilter();
      }
      return NotesViewContent(lensNotes);
    },
  );
}
