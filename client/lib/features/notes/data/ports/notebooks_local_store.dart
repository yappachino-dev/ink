import 'dart:typed_data';

import 'package:ink/core/services/sync/sync_types.dart';
import 'package:ink/features/notes/domain/entities/encrypted_notebook.dart';

abstract interface class NotebooksLocalStore {
  Future<EncryptedNotebook> createNotebook(Uint8List encryptedContent);
  Future<void> saveNotebook(EncryptedNotebook notebook);
  Future<EncryptedNotebook?> getNotebook(String id);
  Future<List<EncryptedNotebook>> getAllNotebooks();
  Future<void> deleteNotebook(String id);
  Future<List<EncryptedNotebook>> getPendingNotebooks();
  Future<List<EncryptedNotebook>> getNotebooksByIds(List<String> ids);
  Future<void> acknowledgePushedNotebooks(List<SyncAck> acknowledgements);
  Future<void> applyRemoteNotebooks(List<EncryptedNotebook> remoteData);
}
