import 'package:drift/drift.dart';
import 'package:ink/app/database/database.dart';
import 'package:ink/core/domain/result.dart';
import 'package:ink/core/infrastructure/data_source_runner.dart';
import 'package:ink/core/services/sync/sync_status.dart';
import 'package:ink/core/services/sync/sync_types.dart';
import 'package:ink/features/notes/data/mappers/encrypted_note_local_mapper.dart';
import 'package:ink/features/notes/data/mappers/encrypted_project_local_mapper.dart';
import 'package:ink/features/notes/data/notes_sync_engine.dart';
import 'package:ink/features/notes/data/projects_sync_engine.dart';
import 'package:ink/features/notes/data/sources/notes_local_data_source.dart';
import 'package:ink/features/notes/data/sources/projects_local_data_source.dart';
import 'package:ink/features/notes/domain/entities/encrypted_note.dart';
import 'package:ink/features/notes/domain/entities/encrypted_project.dart';
import 'package:ink/features/notes/domain/failures/notes_failure.dart';
import 'package:ink/features/notes/domain/notes_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'unified_notes_repository.g.dart';

class UnifiedNotesRepository
    with DataSourceRunner
    implements NotesRepository, NotesSyncEngine, ProjectsSyncEngine {
  UnifiedNotesRepository({
    required NotesLocalDataSource localNotes,
    required ProjectsLocalDataSource localProjects,
  }) : _localNotes = localNotes,
       _localProjects = localProjects;

  final NotesLocalDataSource _localNotes;
  final ProjectsLocalDataSource _localProjects;

  // --- Repository interface implementation ---

  @override
  Future<Result<EncryptedNote, NotesFailure>> createNote(
    Uint8List encryptedTitle,
    Uint8List encryptedContent,
    String? projectId,
  ) async {
    final companion = NotesCompanion.insert(
      encryptedTitle: encryptedTitle,
      encryptedContent: encryptedContent,
      projectId: Value(projectId),
    );

    final result = await localRunner(
      call: () => _localNotes.create(companion),
      mapCore: NotesCoreFailure.new,
    );

    return result.map((model) => model.toDomain());
  }

  @override
  Future<Result<void, NotesFailure>> saveNote(EncryptedNote note) async {
    return localRunner(
      call: () => _localNotes.save(note.toCompanion()),
      mapCore: NotesCoreFailure.new,
    );
  }

  @override
  Future<Result<EncryptedNote?, NotesFailure>> getNote(String id) async {
    final result = await localRunner(
      call: () => _localNotes.get(id),
      mapCore: NotesCoreFailure.new,
    );

    return result.map((model) => model?.toDomain());
  }

  @override
  Future<Result<List<EncryptedNote>, NotesFailure>> getAllNotes() async {
    final result = await localRunner(
      call: _localNotes.getAll,
      mapCore: NotesCoreFailure.new,
    );

    return result.map(
      (models) => models.map((model) => model.toDomain()).toList(),
    );
  }

  @override
  Future<Result<void, NotesFailure>> deleteNote(String id) {
    return localRunner(
      call: () => _localNotes.delete(id),
      mapCore: NotesCoreFailure.new,
    );
  }

  @override
  Future<Result<EncryptedProject, NotesFailure>> createProject(
    Uint8List encryptedContent,
  ) async {
    final companion = ProjectsCompanion.insert(
      encryptedContent: encryptedContent,
    );

    final result = await localRunner(
      call: () => _localProjects.create(companion),
      mapCore: NotesCoreFailure.new,
    );

    return result.map((model) => model.toDomain());
  }

  @override
  Future<Result<void, NotesFailure>> saveProject(EncryptedProject note) async {
    return localRunner(
      call: () => _localProjects.save(note.toCompanion()),
      mapCore: NotesCoreFailure.new,
    );
  }

  @override
  Future<Result<EncryptedProject?, NotesFailure>> getProject(String id) async {
    final result = await localRunner(
      call: () => _localProjects.get(id),
      mapCore: NotesCoreFailure.new,
    );

    return result.map((model) => model?.toDomain());
  }

  @override
  Future<Result<List<EncryptedProject>, NotesFailure>> getAllProjects() async {
    final result = await localRunner(
      call: _localProjects.getAll,
      mapCore: NotesCoreFailure.new,
    );

    return result.map(
      (models) => models.map((model) => model.toDomain()).toList(),
    );
  }

  @override
  Future<Result<void, NotesFailure>> deleteProject(String id) {
    return localRunner(
      call: () => _localProjects.delete(id),
      mapCore: NotesCoreFailure.new,
    );
  }

  // --- Notes sync engine interface implementation ---

  @override
  Future<Result<List<EncryptedNote>, NotesFailure>> getPendingNotes() async {
    final result = await localRunner(
      call: _localNotes.getPending,
      mapCore: NotesCoreFailure.new,
    );

    return result.map(
      (models) => models.map((model) => model.toDomain()).toList(),
    );
  }

  @override
  Future<Result<void, NotesFailure>> acknowledgePushedNotes(
    List<SyncAck> acknowledgements,
  ) async {
    return localRunner(
      call: () => _localNotes.acknowledgePushed(acknowledgements),
      mapCore: NotesCoreFailure.new,
    );
  }

  @override
  Future<Result<void, NotesFailure>> applyRemoteNotes(
    List<EncryptedNote> remoteData,
  ) async {
    for (final note in remoteData) {
      final processResult = await _processSingleNoteDelta(note);

      if (processResult case Failure(error: final e)) return Failure(e);
    }

    return const Success(null);
  }

  // --- Projects sync engine interface implementation ---

  @override
  Future<Result<List<EncryptedProject>, NotesFailure>>
  getPendingProjects() async {
    final result = await localRunner(
      call: _localProjects.getPending,
      mapCore: NotesCoreFailure.new,
    );

    return result.map(
      (models) => models.map((model) => model.toDomain()).toList(),
    );
  }

  @override
  Future<Result<void, NotesFailure>> acknowledgePushedProjects(
    List<SyncAck> acknowledgements,
  ) async {
    return localRunner(
      call: () => _localProjects.acknowledgePushed(acknowledgements),
      mapCore: NotesCoreFailure.new,
    );
  }

  @override
  Future<Result<void, NotesFailure>> applyRemoteProjects(
    List<EncryptedProject> remoteData,
  ) async {
    for (final project in remoteData) {
      final processResult = await _processSingleProjectDelta(project);

      if (processResult case Failure(error: final e)) return Failure(e);
    }

    return const Success(null);
  }

  // -- Sync engine logic ---

  Future<Result<void, NotesFailure>> _processSingleNoteDelta(
    EncryptedNote note,
  ) async {
    final getResult = await localRunner(
      call: () => _localNotes.get(note.id),
      mapCore: NotesCoreFailure.new,
    );

    if (getResult case Failure(error: final e)) return Failure(e);
    final noteModel = getResult.unwrap;

    // Note doesn't exist locally
    if (noteModel == null) {
      // Note doesn't exist on server either => skip
      if (note.deletedAt != null) return const Success(null);

      return localRunner(
        call: () => _localNotes.create(note.toCompanion()),
        mapCore: NotesCoreFailure.new,
      );
    }

    // Note has been modified locally and on the server
    if (noteModel.localVersion > noteModel.lastSyncedVersion) {
      return localRunner(
        call: () => _localNotes.saveWithConflict(
          noteModel
              .copyWith(syncStatus: SyncStatus.conflicted)
              .toCompanion(true),
          note.toConflictCompanion(),
        ),
        mapCore: NotesCoreFailure.new,
      );
    }

    // Note hasn't been updated on the server
    if (note.localVersion <= noteModel.lastSyncedVersion) {
      return const Success(null);
    }

    // Note has been deleted on the server
    if (note.deletedAt != null) {
      // Note has been modified locally and deleted on the server
      if (noteModel.localVersion > note.localVersion) {
        return localRunner(
          call: () => _localNotes.saveWithConflict(
            noteModel
                .copyWith(syncStatus: SyncStatus.conflicted)
                .toCompanion(true),
            note.toConflictCompanion(),
          ),
          mapCore: NotesCoreFailure.new,
        );
      }

      return localRunner(
        call: () => _localNotes.delete(note.id),
        mapCore: NotesCoreFailure.new,
      );
    }

    // No conflict => normal update
    return localRunner(
      call: () => _localNotes.save(note.toCompanion()),
      mapCore: NotesCoreFailure.new,
    );
  }

  Future<Result<void, NotesFailure>> _processSingleProjectDelta(
    EncryptedProject project,
  ) async {
    final getResult = await localRunner(
      call: () => _localProjects.get(project.id),
      mapCore: NotesCoreFailure.new,
    );

    if (getResult case Failure(error: final e)) return Failure(e);
    final projectModel = getResult.unwrap;

    // Project doesn't exist locally
    if (projectModel == null) {
      // Project doesn't exist on server either => skip
      if (project.deletedAt != null) return const Success(null);

      return localRunner(
        call: () => _localProjects.create(project.toCompanion()),
        mapCore: NotesCoreFailure.new,
      );
    }

    // LLW update
    if (project.updatedAt.isAfter(projectModel.updatedAt)) {
      // Project has been deleted on the server => delete locally
      if (project.deletedAt != null) {
        return localRunner(
          call: () => _localProjects.delete(projectModel.id),
          mapCore: NotesCoreFailure.new,
        );
      }

      return localRunner(
        call: () => _localProjects.save(
          project.toCompanion(),
        ),
        mapCore: NotesCoreFailure.new,
      );
    }

    return const Success(null);
  }
}

@riverpod
NotesRepository notesRepository(Ref ref) =>
    ref.watch(unifiedNotesRepositoryProvider);

@riverpod
UnifiedNotesRepository unifiedNotesRepository(Ref ref) =>
    UnifiedNotesRepository(
      localNotes: ref.watch(notesLocalDataSourceProvider),
      localProjects: ref.watch(projectsLocalDataSourceProvider),
    );
