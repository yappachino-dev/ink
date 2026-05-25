import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ink/core/services/sync/sync_status.dart';
import 'package:ink/features/notes/domain/task_priority.dart';
import 'package:ink/i18n/strings.g.dart';

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

  bool get isSynced => syncStatus == SyncStatus.synced;

  String get subtitle => content.toPlainText().trim();

  String timeLabel(Translations t) {
    if (dueTime != null) {
      final h = dueTime!.hour.toString().padLeft(2, '0');
      final m = dueTime!.minute.toString().padLeft(2, '0');
      return '$h:$m';
    }
    if (dueDate != null) {
      return '${dueDate!.day} ${t.calendar.months[dueDate!.month - 1]}';
    }
    return t.home.today;
  }
}
