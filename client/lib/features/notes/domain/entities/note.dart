import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ink/core/domain/sync_status.dart';
import 'package:ink/features/notes/domain/task_priority.dart';
import 'package:ink/features/notes/domain/value_objects/note_time.dart';

part 'note.freezed.dart';

@freezed
sealed class Note with _$Note {
  const factory Note({
    required String id,

    required String title,
    required List<dynamic> content,

    required int localVersion,
    required int lastSyncedVersion,
    required SyncStatus syncStatus,

    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,

    String? projectId,

    DateTime? dueDate,
    NoteTime? dueTime,
    int? reminderMinutesBefore,

    @Default(TaskPriority.none) TaskPriority priority,
    @Default(false) bool isCompleted,
  }) = _Note;

  const Note._();
}
