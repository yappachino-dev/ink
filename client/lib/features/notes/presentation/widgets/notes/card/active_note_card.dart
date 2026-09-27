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
        label: note.title,
        // A tappable row announced only as "button" told a screen reader user
        // nothing about which note it was.
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
