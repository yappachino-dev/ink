import 'package:ink/features/notes/domain/entities/note.dart';
import 'package:ink/features/notes/presentation/notifiers/providers/filtered_notes_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'completed_notes_provider.g.dart';

@riverpod
List<Note> completedNotes(Ref ref) {
  final notes = ref.watch(notebookNotesProvider);

  return notes.where((note) => note.isCompleted).toList();
}
