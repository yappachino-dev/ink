import 'package:ink/features/notes/domain/value_objects/note_time.dart';
import 'package:material_ui/material_ui.dart';

extension NoteTimeUiExtension on NoteTime {
  TimeOfDay get timeOfDay => TimeOfDay(hour: hour, minute: minute);
}

extension TimeOfDayDomainExtension on TimeOfDay {
  NoteTime toNoteTime() => (hour: hour, minute: minute);
}
