import 'package:flutter_quill/flutter_quill.dart';
import 'package:ink/features/notes/domain/entities/note.dart';
import 'package:ink/i18n/strings.g.dart';

extension NoteUiExtension on Note {
  String get subtitle => Document.fromJson(content).toPlainText().trim();

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
