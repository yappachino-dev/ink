import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/theme/tokens.dart';
import 'package:ink/features/notes/domain/entities/note.dart';
import 'package:ink/features/notes/presentation/widgets/notes/card/note_card.dart';
import 'package:ink/features/notes/presentation/widgets/notes/card/swipable_card_wrapper.dart';
import 'package:material_ui/material_ui.dart';

class ActiveNoteCard extends ConsumerWidget {
  const ActiveNoteCard({
    required this.note,
    required this.onTap,
    this.projectName,
    this.showCompletion = true,
    this.showPriority = true,
    super.key,
  });

  final Note note;
  final VoidCallback onTap;
  final String? projectName;

  /// Whether the row leads with a completion checkbox.
  ///
  /// Task-forward surfaces keep this on. The All notes lens turns it off, for
  /// the same reason the calendar journal does: the view answers "what do I
  /// have here", and a per-row completion control answers a question that view
  /// was not asked.
  final bool showCompletion;

  /// Whether the row shows the priority flag.
  final bool showPriority;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SwipableCardWrapper(
      note: note,
      child: Semantics(
        button: true,
        // No `label` on purpose. NoteCard already renders the title as a Text,
        // so setting one merged with the descendant and every row announced as
        // "My note, My note". The Text supplies the name, exactly once.
        //
        // Also no `container`, no `explicitChildNodes` and no explicit
        // `onTap`, all three of which were tried. Each one splits the inner
        // GestureDetector into a second node, leaving the row announced as a
        // bare "button" - with or without a name - and the title one level
        // below it. Left to merge, the row is a single node: isButton, one
        // tap, and the title once.
        //
        // The checkbox stays a child of that node rather than a sibling. It
        // keeps its own tap action and checked state, so it is still
        // independently operable; only the grouping differs from what a
        // screen reader would ideally hear. Making it a sibling means hoisting
        // the checkbox out of NoteCard, which would split the single
        // `showCompletion` flag into "lead with a checkbox" and "style
        // completed titles" across every caller.
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: context.ink.container,
              borderRadius: AppRadius.lgRadius,
              border: Border.all(color: context.colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: AppSpacing.card,
              child: NoteCard(
                note: note,
                projectName: projectName,
                showCompletion: showCompletion,
                showPriority: showPriority,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
