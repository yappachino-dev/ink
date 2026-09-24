import 'package:ink/app/database/database.dart';
import 'package:ink/core/services/sync/sync_types.dart';
import 'package:ink/features/notes/data/daos/notes_dao.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notes_local_data_source.g.dart';

class NotesLocalDataSource {
  NotesLocalDataSource({required NotesDao notesDao}) : _notesDao = notesDao;

  final NotesDao _notesDao;

  Future<NoteModel> create(NotesCompanion note) => _notesDao.insertNote(note);

  Future<void> save(NotesCompanion note) => _notesDao.updateNote(note);

  Future<void> acknowledgePushed(
    List<SyncAck> acknowledgements,
  ) => _notesDao.acknowledgePushed(acknowledgements);

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
}

@riverpod
NotesLocalDataSource notesLocalDataSource(Ref ref) => throw StateError(
  'notesLocalDataSourceProvider must be overridden at the app root',
);
