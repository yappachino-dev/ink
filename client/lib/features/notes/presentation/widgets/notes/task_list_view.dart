import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/presentation/extensions/bottom_sheet_extension.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/features/notes/domain/constants.dart';
import 'package:ink/features/notes/presentation/helpers.dart';
import 'package:ink/features/notes/presentation/notifiers/projects_notifier.dart';
import 'package:ink/features/notes/presentation/notifiers/providers/active_notes_provider.dart';
import 'package:ink/features/notes/presentation/notifiers/providers/completed_notes_provider.dart';
import 'package:ink/features/notes/presentation/notifiers/providers/filtered_notes_provider.dart';
import 'package:ink/features/notes/presentation/notifiers/ui_state.dart';
import 'package:ink/features/notes/presentation/widgets/notes/card/active_note_card.dart';
import 'package:ink/features/notes/presentation/widgets/notes/card/completed_note_card.dart';
import 'package:ink/features/notes/presentation/widgets/notes/completed_secion.dart';
import 'package:ink/features/notes/presentation/widgets/notes/note_details_sheet.dart';
import 'package:material_ui/material_ui.dart';

class TaskListView extends ConsumerWidget {
  const TaskListView({required this.title, super.key});

  final String? title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedProjectId = ref.watch(selectedProjectIdProvider);

    if (isContentForwardLens(selectedProjectId)) {
      return _ContentForwardList(title: title);
    }

    return _TaskForwardList(title: title);
  }
}

/// All notes: one flat, reverse-chronological list, ordered by
/// [projectNotesProvider].
///
/// The split into active and completed, and the per-row completion checkbox,
/// both answer "what is left to do". That is a real question for Today and
/// for a notebook, and it is not the question All notes was asked, so neither
/// appears here. A note containing a checklist still contains it; the row
/// simply stops volunteering task state (D-10).
class _ContentForwardList extends ConsumerWidget {
  const _ContentForwardList({this.title});

  final String? title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(projectNotesProvider);
    // A flat cross-notebook list has no other place to say which notebook a
    // note belongs to, so the card carries it.
    final notebooks = ref.watch(projectsProvider).value ?? const [];

    return CustomScrollView(
      slivers: [
        if (title != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(title!, style: context.textTheme.headlineSmall),
            ),
          ),

        SliverList.builder(
          itemCount: notes.length,
          itemBuilder: (ctx, index) {
            final note = notes[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ActiveNoteCard(
                key: ValueKey(note.id),
                note: note,
                projectName: projectName(notebooks, note.projectId),
                showCompletion: false,
                showPriority: false,
                onTap: () => context.showAppBottomSheetLayout<void>(
                  child: NoteDetailsSheet(note: note),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _TaskForwardList extends ConsumerWidget {
  const _TaskForwardList({this.title});

  final String? title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeNotes = ref.watch(activeNotesProvider);
    final completedNotes = ref.watch(completedNotesProvider);

    return CustomScrollView(
      slivers: [
        if (title != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(title!, style: context.textTheme.headlineSmall),
            ),
          ),

        SliverList.builder(
          itemCount: activeNotes.length,
          itemBuilder: (ctx, index) {
            final note = activeNotes[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ActiveNoteCard(
                key: ValueKey(note.id),
                note: note,
                onTap: () => context.showAppBottomSheetLayout<void>(
                  child: NoteDetailsSheet(note: note),
                ),
              ),
            );
          },
        ),

        if (completedNotes.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: CompletedSection(
                children: [
                  ...completedNotes.map(
                    (note) => CompletedNoteCard(
                      key: ValueKey(note.id),
                      note: note,
                      onTap: () => context.showAppBottomSheetLayout<void>(
                        child: NoteDetailsSheet(note: note),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
