import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ink/features/notes/domain/task_priority.dart';
import 'package:ink/features/notes/domain/value_objects/note_time.dart';

part 'note_creation_payload.freezed.dart';

@freezed
sealed class NoteCreationPayload with _$NoteCreationPayload {
  const factory NoteCreationPayload({
    required String title,
    required List<dynamic> content,
    String? projectId,
    DateTime? dueDate,
    NoteTime? dueTime,
    @Default(TaskPriority.none) TaskPriority priority,
    int? reminderMinutesBefore,
  }) = _NoteCreationPayload;
}
