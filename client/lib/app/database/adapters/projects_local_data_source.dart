import 'dart:typed_data';

import 'package:ink/app/database/daos/projects_dao.dart';
import 'package:ink/app/database/database.dart';
import 'package:ink/app/database/mappers/encrypted_project_local_mapper.dart';
import 'package:ink/core/domain/sync_status.dart';
import 'package:ink/core/services/sync/sync_types.dart';
import 'package:ink/features/notes/data/ports/projects_local_store.dart';
import 'package:ink/features/notes/data/sync_delta_resolution.dart';
import 'package:ink/features/notes/domain/entities/encrypted_project.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'projects_local_data_source.g.dart';

class ProjectsLocalDataSource implements ProjectsLocalStore {
  ProjectsLocalDataSource({required ProjectsDao projectsDao})
    : _projectsDao = projectsDao;

  final ProjectsDao _projectsDao;

  Future<ProjectModel> create(ProjectsCompanion note) =>
      _projectsDao.insertProject(note);

  Future<void> save(ProjectsCompanion note) => _projectsDao.updateProject(note);

  Future<void> acknowledgePushed(
    List<SyncAck> acknowledgements,
  ) => _projectsDao.acknowledgePushed(acknowledgements);

  Future<ProjectModel?> get(String id) => _projectsDao.getProject(id);

  Future<List<ProjectModel>> getAll() => _projectsDao.getAll();

  Future<List<ProjectModel>> getByIds(List<String> ids) =>
      _projectsDao.getByIds(ids);

  Future<void> applyRemoteDeltas({
    List<ProjectsCompanion> upserts = const [],
    List<String> deletes = const [],
    List<(ProjectsCompanion project, ProjectConflictsCompanion conflict)>
        conflicts =
        const [],
  }) => _projectsDao.applyRemoteDeltas(
    upserts: upserts,
    deletes: deletes,
    conflicts: conflicts,
  );

  Future<List<ProjectModel>> getPending() => _projectsDao.getPending();

  Future<void> delete(String id) => _projectsDao.deleteProject(id);

  @override
  Future<EncryptedProject> createProject(Uint8List encryptedContent) async {
    final model = await _projectsDao.insertProject(
      ProjectsCompanion.insert(encryptedContent: encryptedContent),
    );
    return model.toDomain();
  }

  @override
  Future<void> saveProject(EncryptedProject project) =>
      _projectsDao.updateProject(project.toCompanion());

  @override
  Future<EncryptedProject?> getProject(String id) async =>
      (await _projectsDao.getProject(id))?.toDomain();

  @override
  Future<List<EncryptedProject>> getAllProjects() async =>
      (await _projectsDao.getAll()).map((model) => model.toDomain()).toList();

  @override
  Future<void> deleteProject(String id) => _projectsDao.deleteProject(id);

  @override
  Future<List<EncryptedProject>> getPendingProjects() async =>
      (await _projectsDao.getPending())
          .map((model) => model.toDomain())
          .toList();

  @override
  Future<List<EncryptedProject>> getProjectsByIds(List<String> ids) async =>
      (await _projectsDao.getByIds(
        ids,
      )).map((model) => model.toDomain()).toList();

  @override
  Future<void> acknowledgePushedProjects(List<SyncAck> acknowledgements) =>
      _projectsDao.acknowledgePushed(acknowledgements);

  @override
  Future<void> applyRemoteProjects(List<EncryptedProject> remoteData) async {
    if (remoteData.isEmpty) return;

    final existingModels = await _projectsDao.getByIds(
      remoteData.map((project) => project.id).toList(),
    );
    final existing = {for (final model in existingModels) model.id: model};
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

    if (upserts.isNotEmpty || deletes.isNotEmpty || conflicts.isNotEmpty) {
      await _projectsDao.applyRemoteDeltas(
        upserts: upserts,
        deletes: deletes,
        conflicts: conflicts,
      );
    }
  }
}

@riverpod
ProjectsLocalDataSource projectsLocalDataSource(Ref ref) => throw StateError(
  'projectsLocalStoreProvider must be overridden at the app root',
);
