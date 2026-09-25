import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/presentation/extensions/bottom_sheet_extension.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/features/notes/presentation/notifiers/providers/active_notes_provider.dart';
import 'package:ink/features/notes/presentation/notifiers/providers/completed_notes_provider.dart';
import 'package:ink/features/notes/presentation/widgets/notes/card/active_note_card.dart';
import 'package:ink/features/notes/presentation/widgets/notes/card/completed_note_card.dart';
import 'package:ink/features/notes/presentation/widgets/notes/completed_secion.dart';
import 'package:ink/features/notes/presentation/widgets/notes/note_details_sheet.dart';
import 'package:material_ui/material_ui.dart';

class TaskListView extends ConsumerWidget {
  const TaskListView({
    required this.title,
    super.key,
  });

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
                        child: NoteDetailsSheet(
                          note: note,
                        ),
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
