import 'dart:typed_data';

import 'package:ink/core/services/sync/sync_types.dart';
import 'package:ink/features/notes/domain/entities/encrypted_note.dart';
import 'package:ink/features/notes/domain/entities/note_metadata.dart';

abstract interface class NotesLocalStore {
  Future<EncryptedNote> createNote(
    Uint8List encryptedTitle,
    Uint8List encryptedContent,
    String? notebookId,
  );

  Future<void> saveNote(EncryptedNote note);
  Future<EncryptedNote?> getNote(String id);
  Future<List<EncryptedNote>> getAllNotes();
  Future<void> deleteNote(String id);
  Future<List<EncryptedNote>> getPendingNotes();
  Future<List<EncryptedNote>> getNotesByIds(List<String> ids);
  Future<void> acknowledgePushedNotes(List<SyncAck> acknowledgements);
  Future<void> applyRemoteNotes(List<EncryptedNote> remoteData);

  /// Ids of notes whose derived-metadata cache was written by an older build.
  ///
  /// Rows migrate in with the derived columns empty and `metadata_version` 0.
  /// They are repaired once, from a layer that holds the key.
  Future<List<String>> findStaleMetadataNoteIds(int currentVersion);

  /// Writes derived metadata only. Never touches ciphertext, versions, or sync
  /// state, so a repair cannot mark a note as needing a push.
  Future<void> writeNoteMetadata(Map<String, NoteMetadata> byNoteId);
}
