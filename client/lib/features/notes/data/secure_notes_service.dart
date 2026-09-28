import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:ink/core/domain/core_failure.dart';
import 'package:ink/core/domain/result.dart';
import 'package:ink/core/infrastructure/crypto/crypto.dart';
import 'package:ink/core/infrastructure/logger.dart';
import 'package:ink/core/services/session/crypto_session.dart';
import 'package:ink/core/services/session/session_exceptions.dart';
import 'package:ink/core/services/session/session_manager.dart';
import 'package:ink/core/services/sync/sync_orchestrator.dart';
import 'package:ink/features/notes/data/models/note_payload.dart';
import 'package:ink/features/notes/data/models/notebook_payload.dart';
import 'package:ink/features/notes/data/note_decryptor.dart';
import 'package:ink/features/notes/data/unified_notes_repository.dart';
import 'package:ink/features/notes/domain/entities/encrypted_note.dart';
import 'package:ink/features/notes/domain/entities/encrypted_notebook.dart';
import 'package:ink/features/notes/domain/entities/note.dart';
import 'package:ink/features/notes/domain/entities/note_metadata.dart';
import 'package:ink/features/notes/domain/entities/notebook.dart';
import 'package:ink/features/notes/domain/failures/notes_failure.dart';
import 'package:ink/features/notes/domain/mappers/notebooks_mapper.dart';
import 'package:ink/features/notes/domain/mappers/notes_mapper.dart';
import 'package:ink/features/notes/domain/models/note_creation_payload.dart';
import 'package:ink/features/notes/domain/models/notebook_creation_payload.dart';
import 'package:ink/features/notes/domain/notes_repository.dart';
import 'package:ink/features/notes/domain/notes_service.dart';
import 'package:ink/features/notes/domain/value_objects/note_time.dart';
import 'package:material_ui/material_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'secure_notes_service.g.dart';

class SecureNotesService implements NotesService {
  SecureNotesService({
    required EncryptionService encryption,
    required CryptoSession cryptoSession,
    required NotesRepository repository,
    required SyncOrchestrator sync,
    NoteDecryptor? decryptor,
  }) : _encryption = encryption,
       _cryptoSession = cryptoSession,
       _repository = repository,
       _sync = sync,
       _decryptor = decryptor ?? NoteDecryptor(encryption);

  final EncryptionService _encryption;
  final CryptoSession _cryptoSession;
  final NotesRepository _repository;
  final SyncOrchestrator _sync;

  /// Shared with the sync path so both decrypt identically.
  final NoteDecryptor _decryptor;

  @override
  Future<Result<Note, NotesFailure>> createNote(NoteCreationPayload payload) {
    return _guard(() async {
      final masterKey = _cryptoSession.masterKey;

      final p = NotePayload(
        quillData: payload.content,
        dueDate: payload.dueDate,
        dueTime: _toTimeOfDay(payload.dueTime),
        priority: payload.priority,
        reminderMinutesBefore: payload.reminderMinutesBefore,
      );

      final plainContent = jsonEncode(p.toJson());

      final encryptedTitle = await _encryption.encryptString(
        payload.title,
        masterKey,
      );
      final encryptedContent = await _encryption.encryptString(
        plainContent,
        masterKey,
      );

      final result = await _repository.createNote(
        encryptedTitle,
        encryptedContent,
        payload.notebookId,
      );
      if (result case Failure(error: final e)) return Failure(e);
      final encryptedNote = result.unwrap;

      _scheduleSync();
      final note = await _decryptNote(encryptedNote, masterKey);

      return Success(note);
    });
  }

  @override
  Future<Result<void, NotesFailure>> saveNote(Note note) async {
    return _guard(() async {
      final masterKey = _cryptoSession.masterKey;

      final payload = NotePayload(
        quillData: note.content,
        isCompleted: note.isCompleted,
        dueDate: note.dueDate,
        dueTime: _toTimeOfDay(note.dueTime),
        priority: note.priority,
        reminderMinutesBefore: note.reminderMinutesBefore,
      );

      final plainContent = jsonEncode(payload.toJson());

      final encryptedTitle = await _encryption.encryptString(
        note.title,
        masterKey,
      );
      final encryptedContent = await _encryption.encryptString(
        plainContent,
        masterKey,
      );

      final encryptedNote = note.toEncrypted(
        encryptedTitle: encryptedTitle,
        encryptedContent: encryptedContent,
      );

      final result = await _repository.saveNote(encryptedNote);
      if (result case Failure(error: final e)) return Failure(e);

      _scheduleSync();
      return result;
    });
  }

  @override
  Future<Result<Note?, NotesFailure>> getNote(String id) async {
    return _guard(() async {
      final masterKey = _cryptoSession.masterKey;

      final encryptedNoteResult = await _repository.getNote(id);
      if (encryptedNoteResult case Failure(error: final e)) return Failure(e);

      final encryptedNote = encryptedNoteResult.unwrap;

      if (encryptedNote == null) {
        return const Failure(IdNotFound());
      }

      final note = await _decryptNote(encryptedNote, masterKey);

      return Success(note);
    });
  }

  @override
  Future<Result<List<Note>, NotesFailure>> getAllNotes() async {
    return _guard(() async {
      final masterKey = _cryptoSession.masterKey;

      final encryptedNoteResult = await _repository.getAllNotes();
      if (encryptedNoteResult case Failure(error: final e)) return Failure(e);

      final encryptedNotes = encryptedNoteResult.unwrap;

      if (encryptedNotes.isEmpty) return const Success([]);

      // Repairs rows that predate the derived columns, before they are read, so
      // a filter never sees a half-populated cache. No-op once every row is
      // current, and the guard query is a single indexed lookup.
      await _backfillMetadata(encryptedNotes, masterKey);

      final notes = await Future.wait(
        encryptedNotes.map((e) => _decryptNote(e, masterKey)),
      );

      return Success(notes);
    });
  }

  /// Fills the derived-metadata cache for rows written by an older build.
  ///
  /// Runs here rather than in the migration because the derivation needs the
  /// key, and `app/database` must not hold one. Reads the rows already loaded
  /// for the caller's read, so it costs no extra query beyond the staleness
  /// check itself.
  Future<void> _backfillMetadata(
    List<EncryptedNote> notes,
    Uint8List masterKey,
  ) async {
    final staleResult = await _repository.findStaleMetadataNoteIds(
      noteMetadataVersion,
    );
    if (staleResult case Failure(:final error)) {
      // A read must not fail because a cache is behind: the notes are still
      // readable without it, they just filter poorly until the next attempt.
      logger.w('note metadata backfill lookup failed', error: error);
      return;
    }

    final stale = staleResult.unwrap.toSet();
    if (stale.isEmpty) return;

    final repaired = <String, NoteMetadata>{};
    for (final note in notes.where((n) => stale.contains(n.id))) {
      try {
        final decrypted = await _decryptNote(note, masterKey);
        repaired[note.id] = NoteMetadataDerivation.derive(
          title: decrypted.title,
          content: decrypted.content,
          dueDate: decrypted.dueDate,
        );
      } on Object {
        // Unreadable content still gets a current-version row, or the next
        // read would retry it forever. The payload is left untouched.
        repaired[note.id] = const NoteMetadata();
      }
    }

    if (repaired.isEmpty) return;

    final writeResult = await _repository.writeNoteMetadata(repaired);
    if (writeResult case Failure(:final error)) {
      logger.w('note metadata backfill write failed', error: error);
    }
  }

  @override
  Future<Result<void, NotesFailure>> deleteNote(Note note) {
    return _guard(() async {
      final result = await _repository.deleteNote(note.id);
      if (result case Failure(error: final e)) return Failure(e);

      _scheduleSync();
      return result;
    });
  }

  void _scheduleSync() {
    unawaited(_sync.performSync());
  }

  Future<Note> _decryptNote(EncryptedNote encryptedNote, Uint8List masterKey) =>
      _decryptor.decrypt(encryptedNote, masterKey);

  @override
  Future<Result<Notebook, NotesFailure>> createNotebook(
    NotebookCreationPayload payload,
  ) {
    return _guard(() async {
      final masterKey = _cryptoSession.masterKey;

      final p = NotebookPayload(
        title: payload.title,
        emoji: payload.emoji,
        colorValue: Color(payload.colorValue),
      );

      final plainContent = jsonEncode(p.toJson());

      final encryptedContent = await _encryption.encryptString(
        plainContent,
        masterKey,
      );

      final result = await _repository.createNotebook(encryptedContent);
      if (result case Failure(error: final e)) return Failure(e);
      final encryptedNotebook = result.unwrap;

      _scheduleSync();
      final notebook = await _decryptNotebook(encryptedNotebook, masterKey);

      return Success(notebook);
    });
  }

  @override
  Future<Result<void, NotesFailure>> saveNotebook(Notebook notebook) {
    return _guard(() async {
      final masterKey = _cryptoSession.masterKey;

      final payload = NotebookPayload(
        title: notebook.title,
        emoji: notebook.emoji,
        colorValue: Color(notebook.colorValue),
      );

      final plainContent = jsonEncode(payload.toJson());

      final encryptedContent = await _encryption.encryptString(
        plainContent,
        masterKey,
      );

      final encryptedNotebook = notebook.toEncrypted(
        encryptedContent: encryptedContent,
      );

      final result = await _repository.saveNotebook(encryptedNotebook);
      if (result case Failure(error: final e)) return Failure(e);

      _scheduleSync();
      return result;
    });
  }

  @override
  Future<Result<Notebook?, NotesFailure>> getNotebook(String id) {
    return _guard(() async {
      final masterKey = _cryptoSession.masterKey;

      final encryptedNotebookResult = await _repository.getNotebook(id);
      if (encryptedNotebookResult case Failure(error: final e)) {
        return Failure(e);
      }

      final encryptedNotebook = encryptedNotebookResult.unwrap;

      if (encryptedNotebook == null) {
        return const Failure(IdNotFound());
      }

      final note = await _decryptNotebook(encryptedNotebook, masterKey);

      return Success(note);
    });
  }

  @override
  Future<Result<List<Notebook>, NotesFailure>> getAllNotebooks() {
    return _guard(() async {
      final masterKey = _cryptoSession.masterKey;

      final encryptedNotebooksResult = await _repository.getAllNotebooks();
      if (encryptedNotebooksResult case Failure(error: final e)) {
        return Failure(e);
      }

      final encryptedNotebooks = encryptedNotebooksResult.unwrap;

      if (encryptedNotebooks.isEmpty) return const Success([]);

      final notebooks = await Future.wait(
        encryptedNotebooks.map((e) => _decryptNotebook(e, masterKey)),
      );

      return Success(notebooks);
    });
  }

  @override
  Future<Result<void, NotesFailure>> deleteNotebook(Notebook notebook) {
    return _guard(() async {
      final result = await _repository.deleteNotebook(notebook.id);
      if (result case Failure(error: final e)) return Failure(e);

      _scheduleSync();
      return result;
    });
  }

  Future<Notebook> _decryptNotebook(
    EncryptedNotebook encryptedNotebook,
    Uint8List masterKey,
  ) async {
    final plainContent = await _encryption.decryptString(
      encryptedNotebook.encryptedContent,
      masterKey,
    );

    final notebookPayload = NotebookPayload.fromJson(
      jsonDecode(plainContent) as Map<String, dynamic>,
    );

    final notebook = encryptedNotebook.toNotebook(
      title: notebookPayload.title,
      emoji: notebookPayload.emoji,
      colorValue: notebookPayload.colorValue.toARGB32(),
    );

    return notebook;
  }

  TimeOfDay? _toTimeOfDay(NoteTime? time) {
    if (time == null) return null;
    return TimeOfDay(hour: time.hour, minute: time.minute);
  }

  Future<Result<T, NotesFailure>> _guard<T>(
    Future<Result<T, NotesFailure>> Function() action,
  ) async {
    try {
      return await action();
    } on SessionLockedException catch (_) {
      return const Failure(SessionLocked());
    } on CryptoException catch (e) {
      return Failure(NotesCoreFailure(CryptoFailure(e.message)));
    } on Exception catch (e, st) {
      logger.e('SecureNotesService operation failed', error: e, stackTrace: st);
      return Failure(NotesCoreFailure(UnexpectedFailure(e)));
    }
  }
}

@riverpod
NotesService secureNotesService(Ref ref) => SecureNotesService(
  encryption: ref.watch(encryptionServiceProvider),
  cryptoSession: ref.watch(cryptoSessionProvider),
  repository: ref.watch(notesRepositoryProvider),
  sync: ref.watch(syncOrchestratorProvider.notifier),
);
