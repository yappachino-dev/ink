import 'package:ink/core/domain/core_failure.dart';
import 'package:ink/features/notes/domain/failures/notes_failure.dart';

extension NotesFailureToCore on NotesFailure {
  CoreFailure toCore() {
    return switch (this) {
      IdNotFound() => const ApiFailure(404, 'The requested item was not found'),
      SessionLocked() => const StorageFailure('Vault session is locked'),
      NotesCoreFailure(:final core) => core,
    };
  }
}
