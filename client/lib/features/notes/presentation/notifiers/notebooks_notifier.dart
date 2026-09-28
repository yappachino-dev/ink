import 'package:ink/core/domain/sync_events.dart';
import 'package:ink/features/notes/domain/entities/notebook.dart';
import 'package:ink/features/notes/domain/models/notebook_creation_payload.dart';
import 'package:ink/features/notes/domain/notes_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notebooks_notifier.g.dart';

@riverpod
class NotebooksNotifier extends _$NotebooksNotifier {
  @override
  Future<List<Notebook>> build() async {
    ref.listen(syncEventsProvider, (previous, next) {
      if (next.value == SyncEvent.completed) {
        ref.invalidateSelf();
      }
    });

    final service = ref.watch(notesServiceProvider);

    final result = await service.getAllNotebooks();

    return result.fold((notebooks) => notebooks, (failure) => throw failure);
  }

  Future<void> createNotebook(NotebookCreationPayload payload) async {
    final currentNotebooks = state.value ?? [];

    final service = ref.read(notesServiceProvider);

    final result = await service.createNotebook(payload);

    result.fold(
      (note) => state = AsyncData([...currentNotebooks, note]),
      (failure) => throw failure,
    );
  }

  Future<void> saveNotebook(Notebook updatedNotebook) async {
    final previousState = state;
    final currentNotebooks = state.value ?? [];

    final index = currentNotebooks.indexWhere(
      (n) => n.id == updatedNotebook.id,
    );

    if (index >= 0) {
      final newList = List<Notebook>.from(currentNotebooks);
      newList[index] = updatedNotebook;
      state = AsyncData(newList);
    } else {
      state = AsyncData([...currentNotebooks, updatedNotebook]);
    }

    final service = ref.read(notesServiceProvider);

    final result = await service.saveNotebook(updatedNotebook);

    return result.fold((_) {}, (failure) {
      state = previousState;
    });
  }

  Future<void> deleteNotebook(Notebook notebook) async {
    final previousState = state;
    final currentNotebooks = state.value ?? [];

    final index = currentNotebooks.indexWhere((n) => n.id == notebook.id);

    if (index >= 0) {
      final newList = List<Notebook>.from(currentNotebooks)..removeAt(index);
      state = AsyncData(newList);
    }
    final service = ref.read(notesServiceProvider);

    final result = await service.deleteNotebook(notebook);

    return result.fold((_) {}, (failure) {
      state = previousState;
    });
  }
}
