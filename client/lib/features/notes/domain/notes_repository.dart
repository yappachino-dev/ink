import 'dart:typed_data';

import 'package:ink/core/domain/result.dart';
import 'package:ink/features/notes/domain/entities/encrypted_note.dart';
import 'package:ink/features/notes/domain/entities/encrypted_project.dart';
import 'package:ink/features/notes/domain/entities/note_metadata.dart';
import 'package:ink/features/notes/domain/failures/notes_failure.dart';

abstract class NotesRepository {
  Future<Result<EncryptedNote, NotesFailure>> createNote(
    Uint8List encryptedTitle,
    Uint8List encryptedContent,
    String? projectId,
  );
  Future<Result<void, NotesFailure>> saveNote(EncryptedNote note);
  Future<Result<EncryptedNote?, NotesFailure>> getNote(String id);
  Future<Result<List<EncryptedNote>, NotesFailure>> getAllNotes();
  Future<Result<void, NotesFailure>> deleteNote(String id);

  /// Ids of notes whose derived-metadata cache predates the current rules.
  ///
  /// Rows created before the derived columns existed migrate in empty, tagged
  /// with a stale version. They are repaired once, from the layer that holds
  /// the key, rather than by the migration — `app/database` has no key and must
  /// not be handed one to fill a cache.
  Future<Result<List<String>, NotesFailure>> findStaleMetadataNoteIds(
    int currentVersion,
  );

  /// Writes derived metadata only. Never alters ciphertext, versions, or sync
  /// state, so repairing a row cannot queue the note for push.
  Future<Result<void, NotesFailure>> writeNoteMetadata(
    Map<String, NoteMetadata> byNoteId,
  );

  Future<Result<EncryptedProject, NotesFailure>> createProject(
    Uint8List encryptedContent,
  );
  Future<Result<void, NotesFailure>> saveProject(EncryptedProject note);
  Future<Result<EncryptedProject?, NotesFailure>> getProject(String id);
  Future<Result<List<EncryptedProject>, NotesFailure>> getAllProjects();
  Future<Result<void, NotesFailure>> deleteProject(String id);
}
