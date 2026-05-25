import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ink/features/notes/domain/task_priority.dart';

part 'note_creation_payload.freezed.dart';

@freezed
sealed class NoteCreationPayload with _$NoteCreationPayload {
  const factory NoteCreationPayload({
    required String title,
    required Document content,
    String? projectId,
    DateTime? dueDate,
    TimeOfDay? dueTime,
    @Default(TaskPriority.none) TaskPriority priority,
    int? reminderMinutesBefore,
  }) = _NoteCreationPayload;
}
