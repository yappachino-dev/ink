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
import 'package:ink/features/notes/data/sync_delta_resolution.dart';
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
    if (remoteData.isEmpty) return const Success(null);

    final existingResult = await localRunner(
      call: () =>
          _localNotes.getByIds(remoteData.map((note) => note.id).toList()),
      mapCore: NotesCoreFailure.new,
    );
    if (existingResult case Failure(error: final e)) return Failure(e);

    final existing = {
      for (final model in existingResult.unwrap) model.id: model,
    };

    final upserts = <NotesCompanion>[];
    final deletes = <String>[];
    final conflicts = <(NotesCompanion, NoteConflictsCompanion)>[];

    for (final delta in remoteData) {
      final localModel = existing[delta.id];

      switch (resolveSyncDelta(
        existsLocally: localModel != null,
        locallyModified:
            localModel != null &&
            localModel.localVersion > localModel.lastSyncedVersion,
        lastSyncedVersion: localModel?.lastSyncedVersion ?? 0,
        incomingVersion: delta.localVersion,
        incomingDeleted: delta.deletedAt != null,
      )) {
        case SyncDeltaResolution.skip:
          break;
        case SyncDeltaResolution.upsert:
          upserts.add(delta.toCompanion());
        case SyncDeltaResolution.deleteLocal:
          deletes.add(delta.id);
        case SyncDeltaResolution.conflict:
          conflicts.add((
            localModel!
                .copyWith(syncStatus: SyncStatus.conflicted)
                .toCompanion(true),
            delta.toConflictCompanion(),
          ));
      }
    }

    if (upserts.isEmpty && deletes.isEmpty && conflicts.isEmpty) {
      return const Success(null);
    }

    return localRunner(
      call: () => _localNotes.applyRemoteDeltas(
        upserts: upserts,
        deletes: deletes,
        conflicts: conflicts,
      ),
      mapCore: NotesCoreFailure.new,
    );
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
    if (remoteData.isEmpty) return const Success(null);

    final existingResult = await localRunner(
      call: () => _localProjects.getByIds(
        remoteData.map((project) => project.id).toList(),
      ),
      mapCore: NotesCoreFailure.new,
    );
    if (existingResult case Failure(error: final e)) return Failure(e);

    final existing = {
      for (final model in existingResult.unwrap) model.id: model,
    };

    final upserts = <ProjectsCompanion>[];
    final deletes = <String>[];
    final conflicts = <(ProjectsCompanion, ProjectConflictsCompanion)>[];

    for (final delta in remoteData) {
      final localModel = existing[delta.id];

      switch (resolveSyncDelta(
        existsLocally: localModel != null,
        locallyModified:
            localModel != null &&
            localModel.localVersion > localModel.lastSyncedVersion,
        lastSyncedVersion: localModel?.lastSyncedVersion ?? 0,
        incomingVersion: delta.localVersion,
        incomingDeleted: delta.deletedAt != null,
      )) {
        case SyncDeltaResolution.skip:
          break;
        case SyncDeltaResolution.upsert:
          upserts.add(delta.toCompanion());
        case SyncDeltaResolution.deleteLocal:
          deletes.add(delta.id);
        case SyncDeltaResolution.conflict:
          conflicts.add((
            localModel!
                .copyWith(syncStatus: SyncStatus.conflicted)
                .toCompanion(true),
            delta.toConflictCompanion(),
          ));
      }
    }

    if (upserts.isEmpty && deletes.isEmpty && conflicts.isEmpty) {
      return const Success(null);
    }

    return localRunner(
      call: () => _localProjects.applyRemoteDeltas(
        upserts: upserts,
        deletes: deletes,
        conflicts: conflicts,
      ),
      mapCore: NotesCoreFailure.new,
    );
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
