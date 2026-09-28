import 'dart:typed_data';

import 'package:ink/app/database/daos/notebooks_dao.dart';
import 'package:ink/app/database/database.dart';
import 'package:ink/app/database/mappers/encrypted_notebook_local_mapper.dart';
import 'package:ink/core/domain/sync_status.dart';
import 'package:ink/core/services/sync/sync_types.dart';
import 'package:ink/features/notes/data/ports/notebooks_local_store.dart';
import 'package:ink/features/notes/data/sync_delta_resolution.dart';
import 'package:ink/features/notes/domain/entities/encrypted_notebook.dart';

class NotebooksLocalDataSource implements NotebooksLocalStore {
  NotebooksLocalDataSource({required NotebooksDao notebooksDao})
    : _notebooksDao = notebooksDao;

  final NotebooksDao _notebooksDao;

  Future<NotebookModel> create(NotebooksCompanion note) =>
      _notebooksDao.insertNotebook(note);

  Future<void> save(NotebooksCompanion note) =>
      _notebooksDao.updateNotebook(note);

  Future<void> acknowledgePushed(List<SyncAck> acknowledgements) =>
      _notebooksDao.acknowledgePushed(acknowledgements);

  Future<NotebookModel?> get(String id) => _notebooksDao.getNotebook(id);

  Future<List<NotebookModel>> getAll() => _notebooksDao.getAll();

  Future<List<NotebookModel>> getByIds(List<String> ids) =>
      _notebooksDao.getByIds(ids);

  Future<void> applyRemoteDeltas({
    List<NotebooksCompanion> upserts = const [],
    List<String> deletes = const [],
    List<(NotebooksCompanion notebook, NotebookConflictsCompanion conflict)>
        conflicts =
        const [],
  }) => _notebooksDao.applyRemoteDeltas(
    upserts: upserts,
    deletes: deletes,
    conflicts: conflicts,
  );

  Future<List<NotebookModel>> getPending() => _notebooksDao.getPending();

  Future<void> delete(String id) => _notebooksDao.deleteNotebook(id);

  @override
  Future<EncryptedNotebook> createNotebook(Uint8List encryptedContent) async {
    final model = await _notebooksDao.insertNotebook(
      NotebooksCompanion.insert(encryptedContent: encryptedContent),
    );
    return model.toDomain();
  }

  @override
  Future<void> saveNotebook(EncryptedNotebook notebook) =>
      _notebooksDao.updateNotebook(notebook.toCompanion());

  @override
  Future<EncryptedNotebook?> getNotebook(String id) async =>
      (await _notebooksDao.getNotebook(id))?.toDomain();

  @override
  Future<List<EncryptedNotebook>> getAllNotebooks() async =>
      (await _notebooksDao.getAll()).map((model) => model.toDomain()).toList();

  @override
  Future<void> deleteNotebook(String id) => _notebooksDao.deleteNotebook(id);

  @override
  Future<List<EncryptedNotebook>> getPendingNotebooks() async =>
      (await _notebooksDao.getPending())
          .map((model) => model.toDomain())
          .toList();

  @override
  Future<List<EncryptedNotebook>> getNotebooksByIds(List<String> ids) async =>
      (await _notebooksDao.getByIds(
        ids,
      )).map((model) => model.toDomain()).toList();

  @override
  Future<void> acknowledgePushedNotebooks(List<SyncAck> acknowledgements) =>
      _notebooksDao.acknowledgePushed(acknowledgements);

  @override
  Future<void> applyRemoteNotebooks(List<EncryptedNotebook> remoteData) async {
    if (remoteData.isEmpty) return;

    final existingModels = await _notebooksDao.getByIds(
      remoteData.map((notebook) => notebook.id).toList(),
    );
    final existing = {for (final model in existingModels) model.id: model};
    final upserts = <NotebooksCompanion>[];
    final deletes = <String>[];
    final conflicts = <(NotebooksCompanion, NotebookConflictsCompanion)>[];

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
      await _notebooksDao.applyRemoteDeltas(
        upserts: upserts,
        deletes: deletes,
        conflicts: conflicts,
      );
    }
  }
}
