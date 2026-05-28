import 'package:ink/core/domain/result.dart';
import 'package:ink/core/services/sync/sync_types.dart';
import 'package:ink/features/notes/domain/entities/encrypted_project.dart';
import 'package:ink/features/notes/domain/failures/notes_failure.dart';

abstract interface class ProjectsSyncEngine {
  Future<Result<List<EncryptedProject>, NotesFailure>> getPendingProjects();

  Future<Result<void, NotesFailure>> acknowledgePushedProjects(
    List<SyncAck> acknowledgements,
  );

  Future<Result<void, NotesFailure>> applyRemoteProjects(
    List<EncryptedProject> remoteData,
  );
}
