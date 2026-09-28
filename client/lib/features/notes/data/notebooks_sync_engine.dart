import 'package:ink/core/domain/result.dart';
import 'package:ink/core/services/sync/sync_types.dart';
import 'package:ink/features/notes/domain/entities/encrypted_notebook.dart';
import 'package:ink/features/notes/domain/failures/notes_failure.dart';

abstract interface class NotebooksSyncEngine {
  Future<Result<List<EncryptedNotebook>, NotesFailure>> getPendingNotebooks();

  Future<Result<void, NotesFailure>> acknowledgePushedNotebooks(
    List<SyncAck> acknowledgements,
  );

  Future<Result<void, NotesFailure>> applyRemoteNotebooks(
    List<EncryptedNotebook> remoteData,
  );
}
