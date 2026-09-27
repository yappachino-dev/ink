import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/theme/tokens.dart';
import 'package:ink/features/notes/domain/entities/note.dart';
import 'package:ink/features/notes/domain/quill_delta.dart';
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
    this.showMeta = true,
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

  /// Whether to show the due / notebook / priority row at all.
  final bool showMeta;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showDescription = ref.watch(showDescriptionProvider);

    // The cached preview when the note came from the local store, derived only
    // as a fallback for notes built in memory.
    final preview = note.preview.isNotEmpty
        ? note.preview
        : notePreviewText(note.content);

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
              side: BorderSide(color: context.colorScheme.primary, width: 1.5),
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.xsRadius,
              ),
            ),
          ),

          const SizedBox(width: AppSpacing.md),
        ],

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
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

              if (showDescription && preview.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),

                Text(
                  preview,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.theme.hintColor,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              if (showMeta &&
                  (note.dueDate != null ||
                      (projectName?.isNotEmpty ?? false) ||
                      (showPriority &&
                          note.priority != TaskPriority.none))) ...[
                const SizedBox(height: 6),

                NoteMetaRow(
                  note: note,
                  projectName: projectName,
                  showPriority: showPriority,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// The due date, notebook and priority, in one row beneath the content.
///
/// These are the signals the editor's meta bar already exposes, so a note reads
/// the same way wherever it is shown. Priority used to lead the title as an
/// icon; it is task metadata, and this is where task metadata belongs.
class NoteMetaRow extends StatelessWidget {
  const NoteMetaRow({
    required this.note,
    this.projectName,
    this.showPriority = true,
    super.key,
  });

  final Note note;
  final String? projectName;
  final bool showPriority;

  @override
  Widget build(BuildContext context) {
    final hint = context.theme.hintColor;
    final parts = <(IconData, String, Color?)>[
      if (note.dueDate != null)
        (Icons.event_outlined, note.timeLabel(context.t), null),
      if (projectName != null && projectName!.isNotEmpty)
        (Icons.folder_outlined, projectName!, null),
      if (showPriority && note.priority != TaskPriority.none)
        (
          Icons.flag_outlined,
          note.priority.label(context.t),
          note.priority.color,
        ),
    ];

    if (parts.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: [
        for (final (icon, text, color) in parts)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: AppSize.iconSmall, color: color ?? hint),
              const SizedBox(width: AppSpacing.xs),
              Text(
                text,
                style: context.textTheme.labelSmall?.copyWith(
                  color: color ?? hint,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
