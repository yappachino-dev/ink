import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/presentation/app_sizes.dart' as sizes;
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/theme/tokens.dart';
import 'package:ink/features/notes/domain/entities/note.dart';
import 'package:ink/features/notes/domain/task_priority.dart';
import 'package:ink/features/notes/presentation/extensions/note_ui_extension.dart';
import 'package:ink/features/notes/presentation/extensions/task_priority_ui_extension.dart';
import 'package:ink/features/notes/presentation/notifiers/notes_notifier.dart';
import 'package:ink/features/notes/presentation/notifiers/ui_state.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';

class NoteCard extends ConsumerWidget {
  const NoteCard({
    required this.note,
    this.projectName,
    this.showCompletion = true,
    this.showPriority = true,
    super.key,
  });

  final Note note;
  final String? projectName;

  /// Whether to lead the row with a completion checkbox.
  ///
  /// Task-forward surfaces (Today, Overdue) keep this on. A journalled day's
  /// entries turn it off: the calendar answers "what did I write here", and a
  /// per-row completion control answers a question that view was not asked.
  final bool showCompletion;

  /// Whether to show the priority flag.
  final bool showPriority;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showDescription = ref.watch(showDescriptionProvider);

    return Row(
      children: [
        if (showCompletion) ...[
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: note.isCompleted,
              onChanged: (_) =>
                  ref.read(notesProvider.notifier).toggleNote(note),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              activeColor: context.colorScheme.primary,
              side: BorderSide(
                color: context.colorScheme.primary,
                width: 1.5,
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.xsRadius,
              ),
            ),
          ),

          const SizedBox(width: 12),
        ],

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  if (showPriority && note.priority != TaskPriority.none) ...[
                    Icon(
                      Icons.flag,
                      size: sizes.iconSmall,
                      color: note.priority.color,
                    ),

                    const SizedBox(width: 4),
                  ],

                  Expanded(
                    child: Text(
                      note.title,
                      // Completion styling belongs to the task presentation.
                      // When [showCompletion] is off the journal is not
                      // reporting completion at all, so it must not hint at it
                      // with a strikethrough either.
                      style: showCompletion && note.isCompleted
                          ? context.textTheme.titleMedium?.copyWith(
                              color: context.theme.hintColor,
                              decoration: TextDecoration.lineThrough,
                            )
                          : context.textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              if (showDescription && note.subtitle.isNotEmpty) ...[
                const SizedBox(height: 2),

                Text(
                  note.subtitle,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.theme.hintColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),

        const SizedBox(width: 8),

        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (note.dueDate != null)
              Text(
                note.timeLabel(context.t),
                style: context.textTheme.bodySmall,
              ),

            if (projectName != null && projectName!.isNotEmpty) ...[
              if (note.dueDate != null) const SizedBox(height: 2),

              Text(
                projectName!,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.theme.hintColor,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
