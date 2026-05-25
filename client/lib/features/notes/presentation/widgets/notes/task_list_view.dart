import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/presentation/extensions/bottom_sheet_extension.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/features/notes/presentation/notifiers/providers/active_notes_provider.dart';
import 'package:ink/features/notes/presentation/notifiers/providers/completed_notes_provider.dart';
import 'package:ink/features/notes/presentation/widgets/notes/card/active_note_card.dart';
import 'package:ink/features/notes/presentation/widgets/notes/card/completed_note_card.dart';
import 'package:ink/features/notes/presentation/widgets/notes/completed_secion.dart';
import 'package:ink/features/notes/presentation/widgets/notes/note_details_sheet.dart';

class TaskListView extends ConsumerWidget {
  const TaskListView({
    required this.title,
    super.key,
  });

  final String? title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTasks = ref.watch(activeNotesProvider);
    final completedTasks = ref.watch(completedNotesProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
      children: [
        if (title != null) ...[
          Text(title!, style: context.textTheme.headlineSmall),
          const SizedBox(height: 16),
        ],

        ...activeTasks.map(
          (task) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ActiveNoteCard(
              key: ValueKey(task.id),
              note: task,
              onTap: () => context.showAppBottomSheetLayout<void>(
                child: NoteDetailsSheet(
                  note: task,
                ),
              ),
            ),
          ),
        ),

        if (completedTasks.isNotEmpty) ...[
          const SizedBox(height: 4),

          CompletedSection(
            children: [
              ...completedTasks.map(
                (note) => CompletedNoteCard(
                  key: ValueKey(note.id),
                  note: note,
                  onTap: () => context.showAppBottomSheetLayout<void>(
                    child: NoteDetailsSheet(
                      note: note,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
