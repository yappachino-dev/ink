import 'package:ink/core/services/sync/sync_orchestrator.dart';
import 'package:ink/core/services/sync/sync_state.dart';
import 'package:ink/features/notes/data/secure_notes_service.dart';
import 'package:ink/features/notes/domain/entities/note.dart';
import 'package:ink/features/notes/domain/models/note_creation_payload.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notes_notifier.g.dart';

@riverpod
class NotesNotifier extends _$NotesNotifier {
  @override
  Future<Map<String, Note>> build() async {
    ref.listen(syncOrchestratorProvider, (previous, next) {
      if (next is SyncSuccess) {
        ref.invalidateSelf();
      }
    });

    final service = ref.watch(notesServiceProvider);

    final result = await service.getAllNotes();
    return result.fold(
      (notes) => {for (final note in notes) note.id: note},
      (failure) => throw failure,
    );
  }

  Future<void> createNote(NoteCreationPayload payload) async {
    final currentNotes = state.value ?? {};

    final service = ref.read(notesServiceProvider);
    final result = await service.createNote(payload);

    result.fold(
      (note) => state = AsyncData({...currentNotes, note.id: note}),
      (failure) => throw failure,
    );
  }

  Future<void> toggleNote(Note note) {
    return saveNote(note.copyWith(isCompleted: !note.isCompleted));
  }

  Future<void> saveNote(Note updatedNote) async {
    final previousState = state;
    final currentNotes = state.value ?? {};

    state = AsyncData({...currentNotes, updatedNote.id: updatedNote});

    final service = ref.read(notesServiceProvider);
    final result = await service.saveNote(updatedNote);

    return result.fold(
      (_) {},
      (failure) => state = previousState,
    );
  }

  Future<void> deleteNote(Note note) async {
    final previousState = state;
    final currentNotes = state.value ?? {};

    final newMap = Map<String, Note>.from(currentNotes)..remove(note.id);
    state = AsyncData(newMap);

    final service = ref.read(notesServiceProvider);
    final result = await service.deleteNote(note);

    return result.fold(
      (_) {},
      (failure) => state = previousState,
    );
  }
}
