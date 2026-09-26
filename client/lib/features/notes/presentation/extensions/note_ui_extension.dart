import 'package:ink/features/notes/domain/entities/note.dart';
import 'package:ink/features/notes/domain/quill_delta.dart';
import 'package:ink/i18n/strings.g.dart';

extension NoteUiExtension on Note {
  /// Display text for a card. Never throws (F-24).
  ///
  /// Capped and lossy by design, so it must never be used to decide whether a
  /// note changed. Compare `content` directly for that.
  String get subtitle => notePreviewText(content);

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
