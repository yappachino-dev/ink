import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/presentation/extensions/bottom_sheet_extension.dart';
import 'package:ink/features/notes/domain/constants.dart';
import 'package:ink/features/notes/domain/entities/project.dart';
import 'package:ink/features/notes/presentation/notifiers/projects_notifier.dart';
import 'package:ink/features/notes/presentation/notifiers/providers/calendar_notes_provider.dart';
import 'package:ink/features/notes/presentation/widgets/notes/card/active_note_card.dart';
import 'package:ink/features/notes/presentation/widgets/notes/card/completed_note_card.dart';
import 'package:ink/features/notes/presentation/widgets/notes/completed_secion.dart';
import 'package:ink/features/notes/presentation/widgets/notes/note_details_sheet.dart';
import 'package:ink/i18n/strings.g.dart';

class TaskListView extends ConsumerWidget {
  const TaskListView({super.key});

  String _listNameFor(List<Project> allProjects, String projectId) {
    return allProjects.where((p) => p.id == projectId).firstOrNull?.title ??
        t.home.inbox;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allProjects = ref.watch(projectsProvider).value ?? [];
    final activeNotes = ref.watch(activeCalendarNotesProvider);
    final completedNotes = ref.watch(completedCalendarNotesProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      children: [
        ...activeNotes.map(
          (task) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ActiveNoteCard(
              key: ValueKey(task.id),
              note: task,
              projectName: _listNameFor(
                allProjects,
                task.projectId ?? inboxProjectId,
              ),
              onTap: () => context.showAppBottomSheetLayout<void>(
                child: NoteDetailsSheet(
                  note: task,
                ),
              ),
            ),
          ),
        ),

        if (completedNotes.isNotEmpty) ...[
          const SizedBox(height: 4),

          CompletedSection(
            children: [
              ...completedNotes.map(
                (note) => CompletedNoteCard(
                  key: ValueKey(note.id),
                  note: note,
                  projectName: _listNameFor(
                    allProjects,
                    note.projectId ?? inboxProjectId,
                  ),
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
