import 'package:ink/core/domain/result.dart';
import 'package:ink/core/services/sync/sync_types.dart';
import 'package:ink/features/notes/data/dto/project_dto.dart';
import 'package:ink/features/notes/domain/failures/notes_failure.dart';

abstract interface class ProjectsSyncEngine {
  Future<Result<List<ProjectDto>, NotesFailure>> getPendingProjects();

  Future<Result<void, NotesFailure>> acknowledgePushedProjects(
    List<SyncAcknowledgement> acknowledgements,
  );

  Future<Result<void, NotesFailure>> applyRemoteProjects(
    List<ProjectDto> remoteData,
  );
}
