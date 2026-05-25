import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:ink/features/notes/domain/entities/encrypted_note.dart';
import 'package:ink/features/notes/domain/entities/note.dart';
import 'package:ink/features/notes/domain/task_priority.dart';

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
  );
}

extension EncryptedToNote on EncryptedNote {
  Note toNote({
    required String title,
    required Document content,
    required bool isCompleted,
    required TaskPriority priority,

    DateTime? dueDate,
    TimeOfDay? dueTime,
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
