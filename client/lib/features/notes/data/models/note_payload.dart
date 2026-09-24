import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ink/core/infrastructure/serialization/json_helpers.dart';
import 'package:ink/features/notes/domain/task_priority.dart';

part 'note_payload.freezed.dart';
part 'note_payload.g.dart';

@freezed
sealed class NotePayload with _$NotePayload {
  const factory NotePayload({
    required List<dynamic> quillData,
    @Default(false) bool isCompleted,
    DateTime? dueDate,
    @TimeOfDayConverter() TimeOfDay? dueTime,
    @Default(TaskPriority.none) TaskPriority priority,
    int? reminderMinutesBefore,
  }) = _NotePayload;

  factory NotePayload.fromJson(Map<String, dynamic> json) =>
      _$NotePayloadFromJson(json);
}
