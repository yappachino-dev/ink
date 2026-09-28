import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/presentation/theme/tokens.dart';
import 'package:ink/features/notes/domain/entities/note.dart';
import 'package:ink/features/notes/presentation/widgets/notes/card/note_card.dart';
import 'package:ink/features/notes/presentation/widgets/notes/card/swipable_card_wrapper.dart';
import 'package:material_ui/material_ui.dart';

class CompletedNoteCard extends ConsumerWidget {
  const CompletedNoteCard({
    required this.note,
    required this.onTap,
    this.notebookName,
    super.key,
  });

  final Note note;
  final VoidCallback onTap;
  final String? notebookName;

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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: NoteCard(note: note, notebookName: notebookName),
          ),
        ),
      ),
    );
  }
}
