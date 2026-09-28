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

    String? notebookId,

    DateTime? dueDate,
    NoteTime? dueTime,
    int? reminderMinutesBefore,

    @Default(TaskPriority.none) TaskPriority priority,
    @Default(false) bool isCompleted,

    /// Cached plain-text preview, derived once at write time.
    ///
    /// Empty when the note was not read through the local store, so callers
    /// must fall back to deriving it. Display only: it is capped and lossy, and
    /// must never be used to decide whether a note changed.
    @Default('') String preview,
  }) = _Note;

  const Note._();
}
