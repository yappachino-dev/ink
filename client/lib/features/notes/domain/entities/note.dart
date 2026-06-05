import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ink/core/services/sync/sync_status.dart';
import 'package:ink/features/notes/domain/task_priority.dart';

part 'note.freezed.dart';

@freezed
sealed class Note with _$Note {
  const factory Note({
    required String id,

    required String title,
    required Document content,

    required int localVersion,
    required int lastSyncedVersion,
    required SyncStatus syncStatus,

    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,

    String? projectId,

    DateTime? dueDate,
    TimeOfDay? dueTime,
    int? reminderMinutesBefore,

    @Default(TaskPriority.none) TaskPriority priority,
    @Default(false) bool isCompleted,
  }) = _Note;

  const Note._();
}
