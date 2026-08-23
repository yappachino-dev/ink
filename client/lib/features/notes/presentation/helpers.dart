import 'package:flutter/material.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/features/notes/domain/entities/project.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:ink/core/presentation/theme/tokens.dart';

String reminderLabel(int minutes, Translations t) {
  if (minutes == 0) return t.note.reminder.atTime;
  if (minutes < 60) return t.note.reminder.minutes(n: minutes);
  if (minutes < 1440) return t.note.reminder.hours(n: minutes ~/ 60);
  return t.note.reminder.days(n: minutes ~/ 1440);
}

String formatDateTime(DateTime date, TimeOfDay? time, Translations t) {
  final monthName = t.calendar.months[date.month - 1];
  final dateStr = '${date.day} $monthName ${date.year}';
  if (time == null) return dateStr;
  final h = time.hour.toString().padLeft(2, '0');
  final m = time.minute.toString().padLeft(2, '0');
  return '$dateStr $h:$m';
}

String? projectName(List<Project> projects, String? projectId) {
  if (projectId == null) return null;
  return projects.where((p) => p.id == projectId).firstOrNull?.title;
}

Future<bool> confirmDeletion(
  BuildContext context,
  String title,
  String message,
) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      final t = ctx.t;
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgRadius),
        actionsAlignment: MainAxisAlignment.center,
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: context.textTheme.titleLarge,
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(t.common.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: context.colorScheme.error,
            ),
            child: Text(t.common.delete),
          ),
        ],
      );
    },
  );
  return result ?? false;
}
