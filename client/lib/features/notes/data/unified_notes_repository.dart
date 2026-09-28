import 'dart:typed_data';

import 'package:ink/core/domain/result.dart';
import 'package:ink/core/infrastructure/data_source_runner.dart';
import 'package:ink/core/services/sync/sync_types.dart';
import 'package:ink/features/notes/data/notebooks_sync_engine.dart';
import 'package:ink/features/notes/data/notes_sync_engine.dart';
import 'package:ink/features/notes/data/ports/notebooks_local_store.dart';
import 'package:ink/features/notes/data/ports/notes_local_store.dart';
import 'package:ink/features/notes/data/sources/notebooks_local_store_provider.dart';
import 'package:ink/features/notes/data/sources/notes_local_store_provider.dart';
import 'package:ink/features/notes/domain/entities/encrypted_note.dart';
import 'package:ink/features/notes/domain/entities/encrypted_notebook.dart';
import 'package:ink/features/notes/domain/entities/note_metadata.dart';
import 'package:ink/features/notes/domain/failures/notes_failure.dart';
import 'package:ink/features/notes/domain/notes_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'unified_notes_repository.g.dart';

class UnifiedNotesRepository
    with DataSourceRunner
    implements NotesRepository, NotesSyncEngine, NotebooksSyncEngine {
  UnifiedNotesRepository({
    required NotesLocalStore localNotes,
    required NotebooksLocalStore localNotebooks,
  }) : _localNotes = localNotes,
       _localNotebooks = localNotebooks;

  final NotesLocalStore _localNotes;
  final NotebooksLocalStore _localNotebooks;

  @override
  Future<Result<EncryptedNote, NotesFailure>> createNote(
    Uint8List encryptedTitle,
    Uint8List encryptedContent,
    String? notebookId,
  ) {
    return localRunner(
      call: () =>
          _localNotes.createNote(encryptedTitle, encryptedContent, notebookId),
      mapCore: NotesCoreFailure.new,
    );
  }

  @override
  Future<Result<void, NotesFailure>> saveNote(EncryptedNote note) {
    return localRunner(
      call: () => _localNotes.saveNote(note),
      mapCore: NotesCoreFailure.new,
    );
  }

  @override
  Future<Result<EncryptedNote?, NotesFailure>> getNote(String id) {
    return localRunner(
      call: () => _localNotes.getNote(id),
      mapCore: NotesCoreFailure.new,
    );
  }

  @override
  Future<Result<List<EncryptedNote>, NotesFailure>> getAllNotes() {
    return localRunner(
      call: _localNotes.getAllNotes,
      mapCore: NotesCoreFailure.new,
    );
  }

  @override
  Future<Result<void, NotesFailure>> deleteNote(String id) {
    return localRunner(
      call: () => _localNotes.deleteNote(id),
      mapCore: NotesCoreFailure.new,
    );
  }

  @override
  Future<Result<EncryptedNotebook, NotesFailure>> createNotebook(
    Uint8List encryptedContent,
  ) {
    return localRunner(
      call: () => _localNotebooks.createNotebook(encryptedContent),
      mapCore: NotesCoreFailure.new,
    );
  }

  @override
  Future<Result<void, NotesFailure>> saveNotebook(EncryptedNotebook notebook) {
    return localRunner(
      call: () => _localNotebooks.saveNotebook(notebook),
      mapCore: NotesCoreFailure.new,
    );
  }

  @override
  Future<Result<EncryptedNotebook?, NotesFailure>> getNotebook(String id) {
    return localRunner(
      call: () => _localNotebooks.getNotebook(id),
      mapCore: NotesCoreFailure.new,
    );
  }

  @override
  Future<Result<List<EncryptedNotebook>, NotesFailure>> getAllNotebooks() {
    return localRunner(
      call: _localNotebooks.getAllNotebooks,
      mapCore: NotesCoreFailure.new,
    );
  }

  @override
  Future<Result<void, NotesFailure>> deleteNotebook(String id) {
    return localRunner(
      call: () => _localNotebooks.deleteNotebook(id),
      mapCore: NotesCoreFailure.new,
    );
  }

  @override
  Future<Result<List<EncryptedNote>, NotesFailure>> getPendingNotes() {
    return localRunner(
      call: _localNotes.getPendingNotes,
      mapCore: NotesCoreFailure.new,
    );
  }

  @override
  Future<Result<void, NotesFailure>> acknowledgePushedNotes(
    List<SyncAck> acknowledgements,
  ) {
    return localRunner(
      call: () => _localNotes.acknowledgePushedNotes(acknowledgements),
      mapCore: NotesCoreFailure.new,
    );
  }

  @override
  Future<Result<List<String>, NotesFailure>> findStaleMetadataNoteIds(
    int currentVersion,
  ) {
    return localRunner(
      call: () => _localNotes.findStaleMetadataNoteIds(currentVersion),
      mapCore: NotesCoreFailure.new,
    );
  }

  @override
  Future<Result<void, NotesFailure>> writeNoteMetadata(
    Map<String, NoteMetadata> byNoteId,
  ) {
    return localRunner(
      call: () => _localNotes.writeNoteMetadata(byNoteId),
      mapCore: NotesCoreFailure.new,
    );
  }

  @override
  Future<Result<void, NotesFailure>> applyRemoteNotes(
    List<EncryptedNote> remoteData,
  ) {
    return localRunner(
      call: () => _localNotes.applyRemoteNotes(remoteData),
      mapCore: NotesCoreFailure.new,
    );
  }

  @override
  Future<Result<List<EncryptedNotebook>, NotesFailure>> getPendingNotebooks() {
    return localRunner(
      call: _localNotebooks.getPendingNotebooks,
      mapCore: NotesCoreFailure.new,
    );
  }

  @override
  Future<Result<void, NotesFailure>> acknowledgePushedNotebooks(
    List<SyncAck> acknowledgements,
  ) {
    return localRunner(
      call: () => _localNotebooks.acknowledgePushedNotebooks(acknowledgements),
      mapCore: NotesCoreFailure.new,
    );
  }

  @override
  Future<Result<void, NotesFailure>> applyRemoteNotebooks(
    List<EncryptedNotebook> remoteData,
  ) {
    return localRunner(
      call: () => _localNotebooks.applyRemoteNotebooks(remoteData),
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
      localNotes: ref.watch(notesLocalStoreProvider),
      localNotebooks: ref.watch(notebooksLocalStoreProvider),
    );
