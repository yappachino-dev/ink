import 'dart:typed_data';

import 'package:ink/features/notes/domain/entities/encrypted_note.dart';
import 'package:ink/features/notes/domain/entities/note.dart';
import 'package:ink/features/notes/domain/entities/note_metadata.dart';
import 'package:ink/features/notes/domain/task_priority.dart';
import 'package:ink/features/notes/domain/value_objects/note_time.dart';

extension NoteToEncrypted on Note {
  EncryptedNote toEncrypted({
    required Uint8List encryptedTitle,
    required Uint8List encryptedContent,
  }) => EncryptedNote(
    id: id,
    encryptedTitle: encryptedTitle,
    encryptedContent: encryptedContent,

    localVersion: localVersion,
    lastSyncedVersion: lastSyncedVersion,
    syncStatus: syncStatus,

    createdAt: createdAt,
    updatedAt: updatedAt,
    deletedAt: deletedAt,

    projectId: projectId,

    // Derived here, at the point where plaintext and ciphertext coexist. Every
    // local write funnels through this mapper, so this is the only place local
    // metadata has to be computed. Remote writes cannot use it: they arrive as
    // ciphertext with no plaintext anywhere in the pipeline, and are enriched
    // separately before persistence.
    metadata: NoteMetadataDerivation.derive(
      title: title,
      content: content,
      dueDate: dueDate,
    ),
  );
}

extension EncryptedToNote on EncryptedNote {
  Note toNote({
    required String title,
    required List<dynamic> content,
    required bool isCompleted,
    required TaskPriority priority,

    DateTime? dueDate,
    NoteTime? dueTime,
    int? reminderMinutesBefore,
  }) => Note(
    id: id,
    title: title,
    content: content,

    localVersion: localVersion,
    lastSyncedVersion: lastSyncedVersion,
    syncStatus: syncStatus,

    createdAt: createdAt,
    updatedAt: updatedAt,
    deletedAt: deletedAt,

    projectId: projectId,

    dueDate: dueDate,
    dueTime: dueTime,
    reminderMinutesBefore: reminderMinutesBefore,

    priority: priority,
    isCompleted: isCompleted,
  );
}
