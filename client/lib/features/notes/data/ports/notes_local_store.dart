import 'dart:typed_data';

import 'package:ink/core/services/sync/sync_types.dart';
import 'package:ink/features/notes/domain/entities/encrypted_note.dart';

abstract interface class NotesLocalStore {
  Future<EncryptedNote> createNote(
    Uint8List encryptedTitle,
    Uint8List encryptedContent,
    String? projectId,
  );

  Future<void> saveNote(EncryptedNote note);
  Future<EncryptedNote?> getNote(String id);
  Future<List<EncryptedNote>> getAllNotes();
  Future<void> deleteNote(String id);
  Future<List<EncryptedNote>> getPendingNotes();
  Future<List<EncryptedNote>> getNotesByIds(List<String> ids);
  Future<void> acknowledgePushedNotes(List<SyncAck> acknowledgements);
  Future<void> applyRemoteNotes(List<EncryptedNote> remoteData);
}
