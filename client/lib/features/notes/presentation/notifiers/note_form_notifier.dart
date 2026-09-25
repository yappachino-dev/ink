import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ink/features/notes/domain/entities/note.dart';
import 'package:ink/features/notes/domain/task_priority.dart';
import 'package:ink/features/notes/presentation/extensions/note_time_ui_extension.dart';
import 'package:material_ui/material_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'note_form_notifier.freezed.dart';
part 'note_form_notifier.g.dart';

@freezed
sealed class NoteDraftState with _$NoteDraftState {
  const factory NoteDraftState({
    String? projectId,
    DateTime? dueDate,
    TimeOfDay? dueTime,
    int? reminderMinutes,
    @Default(TaskPriority.none) TaskPriority priority,
  }) = _NoteDraftState;
}

@riverpod
class NoteFormNotifier extends _$NoteFormNotifier {
  @override
  NoteDraftState build() => const NoteDraftState();

  void initWithExisting(Note note) => state = state.copyWith(
    projectId: note.projectId,
    dueDate: note.dueDate ?? DateTime.now(),
    dueTime: note.dueTime?.timeOfDay,
    reminderMinutes: note.reminderMinutesBefore,
    priority: note.priority,
  );

  void initWith({
    String? projectId,
    DateTime? dueDate,
  }) {
    state = state.copyWith(
      projectId: projectId ?? state.projectId,
      dueDate: dueDate ?? state.dueDate,
    );
  }

  void updateProjectId(String? projectId) =>
      state = state.copyWith(projectId: projectId);

  void updateDueDate(DateTime? dueDate) =>
      state = state.copyWith(dueDate: dueDate);

  void updateDueTime(TimeOfDay? dueTime) =>
      state = state.copyWith(dueTime: dueTime);

  void updateDueFields(DateTime? dueDate, TimeOfDay? dueTime) =>
      state = state.copyWith(dueDate: dueDate, dueTime: dueTime);

  void nullDueFields() => state = state.copyWith(dueDate: null, dueTime: null);

  void updateReminder(int? minutes) =>
      state = state.copyWith(reminderMinutes: minutes);

  void updatePriority(TaskPriority priority) =>
      state = state.copyWith(priority: priority);
}
