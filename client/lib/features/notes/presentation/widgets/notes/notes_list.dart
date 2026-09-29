import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/presentation/extensions/bottom_sheet_extension.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/theme/tokens.dart';
import 'package:ink/features/notes/domain/constants.dart';
import 'package:ink/features/notes/presentation/helpers.dart';
import 'package:ink/features/notes/presentation/notifiers/notebooks_notifier.dart';
import 'package:ink/features/notes/presentation/notifiers/providers/active_notes_provider.dart';
import 'package:ink/features/notes/presentation/notifiers/providers/completed_notes_provider.dart';
import 'package:ink/features/notes/presentation/notifiers/providers/filtered_notes_provider.dart';
import 'package:ink/features/notes/presentation/notifiers/ui_state.dart';
import 'package:ink/features/notes/presentation/widgets/notes/card/active_note_card.dart';
import 'package:ink/features/notes/presentation/widgets/notes/card/completed_note_card.dart';
import 'package:ink/features/notes/presentation/widgets/notes/completed_section.dart';
import 'package:ink/features/notes/presentation/widgets/notes/note_details_sheet.dart';
import 'package:material_ui/material_ui.dart';

class NotesList extends ConsumerWidget {
  const NotesList({required this.title, super.key});

  final String? title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedNotebookId = ref.watch(selectedNotebookIdProvider);

    if (isContentForwardLens(selectedNotebookId)) {
      return _ContentForwardList(title: title);
    }

    return _TaskForwardList(title: title);
  }
}

/// All notes: one flat, reverse-chronological list, ordered by
/// [notebookNotesProvider].
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
    final notes = ref.watch(notebookNotesProvider);
    // A flat cross-notebook list has no other place to say which notebook a
    // note belongs to, so the card carries it.
    final notebooks = ref.watch(notebooksProvider).value ?? const [];

    return CustomScrollView(
      slivers: [
        if (title != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: Text(title!, style: context.textTheme.headlineSmall),
            ),
          ),

        SliverList.builder(
          itemCount: notes.length,
          itemBuilder: (ctx, index) {
            final note = notes[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: ActiveNoteCard(
                key: ValueKey(note.id),
                note: note,
                notebookName: notebookName(notebooks, note.notebookId),
                showCompletion: false,
                showPriority: false,
                onTap: () => context.showAppBottomSheetLayout<void>(
                  child: NoteDetailsSheet(note: note),
                ),
              ),
            );
          },
        ),

        // See [_TaskForwardList]: clearance for the floating action button,
        // which is Positioned over the list and reserves no space itself. It
        // has to be a trailing sliver inside the scroll view, not an inset on
        // the viewport wrapper, which would shrink the scrollable area and stop
        // the list short of the navigation bar.
        const SliverToBoxAdapter(
          child: SizedBox(height: AppSize.fab + AppSpacing.xxl),
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
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: Text(title!, style: context.textTheme.headlineSmall),
            ),
          ),

        SliverList.builder(
          itemCount: activeNotes.length,
          itemBuilder: (ctx, index) {
            final note = activeNotes[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
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
              padding: const EdgeInsets.only(top: AppSpacing.xs),
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

        // Clearance for the floating action button, which is `Positioned` over
        // this list rather than placed in a layout slot, so nothing reserves
        // space for it. Without this the final card parks underneath the button
        // with its text and tap target covered.
        //
        // A trailing sliver *inside* the scroll view, not a bottom inset on
        // the viewport wrapper: an inset on the wrapper shrinks the scrollable
        // area instead of adding room below the last card, and the list stops
        // short of the navigation bar. That is the exact defect the sibling
        // notes-bottom-clearance test prevents, so the two are in tension by
        // design and this has to be the one that yields.
        //
        // Trailing rather than wrapping the active list, because the completed
        // section renders after it and is what actually ends the scroll.
        const SliverToBoxAdapter(
          child: SizedBox(height: AppSize.fab + AppSpacing.xxl),
        ),
      ],
    );
  }
}
