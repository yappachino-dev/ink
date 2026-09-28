import 'package:drift/drift.dart';
import 'package:ink/app/database/daos/notes_dao.dart';
import 'package:ink/app/database/database.dart';
import 'package:ink/app/database/mappers/encrypted_note_local_mapper.dart';
import 'package:ink/core/domain/sync_status.dart';
import 'package:ink/core/services/sync/sync_types.dart';
import 'package:ink/features/notes/data/ports/notes_local_store.dart';
import 'package:ink/features/notes/data/sync_delta_resolution.dart';
import 'package:ink/features/notes/domain/entities/encrypted_note.dart';
import 'package:ink/features/notes/domain/entities/note_metadata.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notes_local_data_source.g.dart';

class NotesLocalDataSource implements NotesLocalStore {
  NotesLocalDataSource({required NotesDao notesDao}) : _notesDao = notesDao;

  final NotesDao _notesDao;

  Future<NoteModel> create(NotesCompanion note) => _notesDao.insertNote(note);

  Future<void> save(NotesCompanion note) => _notesDao.updateNote(note);

  Future<void> acknowledgePushed(List<SyncAck> acknowledgements) =>
      _notesDao.acknowledgePushed(acknowledgements);

  Future<NoteModel?> get(String id) => _notesDao.getNote(id);

  Future<List<NoteModel>> getAll() => _notesDao.getAllNotes();

  Future<List<NoteModel>> getByIds(List<String> ids) => _notesDao.getByIds(ids);

  Future<void> applyRemoteDeltas({
    List<NotesCompanion> upserts = const [],
    List<String> deletes = const [],
    List<(NotesCompanion note, NoteConflictsCompanion conflict)> conflicts =
        const [],
  }) => _notesDao.applyRemoteDeltas(
    upserts: upserts,
    deletes: deletes,
    conflicts: conflicts,
  );

  Future<List<NoteModel>> getPending() => _notesDao.getPending();

  Future<void> delete(String id) => _notesDao.deleteNote(id);

  @override
  Future<EncryptedNote> createNote(
    Uint8List encryptedTitle,
    Uint8List encryptedContent,
    String? notebookId,
  ) async {
    final model = await _notesDao.insertNote(
      NotesCompanion.insert(
        encryptedTitle: encryptedTitle,
        encryptedContent: encryptedContent,
        notebookId: Value(notebookId),
      ),
    );
    return model.toDomain();
  }

  @override
  Future<void> saveNote(EncryptedNote note) =>
      _notesDao.updateNote(note.toCompanion());

  @override
  Future<EncryptedNote?> getNote(String id) async =>
      (await _notesDao.getNote(id))?.toDomain();

  @override
  Future<List<EncryptedNote>> getAllNotes() async =>
      (await _notesDao.getAllNotes()).map((model) => model.toDomain()).toList();

  @override
  Future<void> deleteNote(String id) => _notesDao.deleteNote(id);

  @override
  Future<List<EncryptedNote>> getPendingNotes() async =>
      (await _notesDao.getPending()).map((model) => model.toDomain()).toList();

  @override
  Future<List<EncryptedNote>> getNotesByIds(List<String> ids) async =>
      (await _notesDao.getByIds(ids)).map((model) => model.toDomain()).toList();

  @override
  Future<void> acknowledgePushedNotes(List<SyncAck> acknowledgements) =>
      _notesDao.acknowledgePushed(acknowledgements);

  @override
  Future<List<String>> findStaleMetadataNoteIds(int currentVersion) =>
      _notesDao.findStaleMetadataNoteIds(currentVersion);

  @override
  Future<void> writeNoteMetadata(Map<String, NoteMetadata> byNoteId) =>
      _notesDao.writeNoteMetadata(byNoteId);

  @override
  Future<void> applyRemoteNotes(List<EncryptedNote> remoteData) async {
    if (remoteData.isEmpty) return;

    final existingModels = await _notesDao.getByIds(
      remoteData.map((note) => note.id).toList(),
    );
    final existing = {for (final model in existingModels) model.id: model};
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

    if (upserts.isNotEmpty || deletes.isNotEmpty || conflicts.isNotEmpty) {
      await _notesDao.applyRemoteDeltas(
        upserts: upserts,
        deletes: deletes,
        conflicts: conflicts,
      );
    }
  }
}

@riverpod
NotesLocalDataSource notesLocalDataSource(Ref ref) => throw StateError(
  'notesLocalStoreProvider must be overridden at the app root',
);
