import 'package:ink/core/domain/result.dart';
import 'package:ink/core/services/sync/sync_types.dart';
import 'package:ink/features/notes/domain/entities/encrypted_note.dart';
import 'package:ink/features/notes/domain/failures/notes_failure.dart';

abstract interface class NotesSyncEngine {
  Future<Result<List<EncryptedNote>, NotesFailure>> getPendingNotes();

  Future<Result<void, NotesFailure>> acknowledgePushedNotes(
    List<SyncAck> acknowledgements,
  );

  Future<Result<void, NotesFailure>> applyRemoteNotes(
    List<EncryptedNote> remoteData,
  );
}
