import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/features/notes/domain/entities/note.dart';
import 'package:ink/features/notes/presentation/widgets/notes/card/note_card.dart';
import 'package:ink/features/notes/presentation/widgets/notes/card/swipable_card_wrapper.dart';
import 'package:material_ui/material_ui.dart';

class CompletedNoteCard extends ConsumerWidget {
  const CompletedNoteCard({
    required this.note,
    required this.onTap,
    this.projectName,
    super.key,
  });

  final Note note;
  final VoidCallback onTap;
  final String? projectName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SwipableCardWrapper(
      note: note,
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: NoteCard(note: note, projectName: projectName),
        ),
      ),
    );
  }
}
