import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/features/notes/domain/entities/note.dart';
import 'package:ink/features/notes/presentation/widgets/notes/card/note_card.dart';
import 'package:ink/features/notes/presentation/widgets/notes/card/swipable_card_wrapper.dart';

class ActiveNoteCard extends ConsumerWidget {
  const ActiveNoteCard({
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
        child: Container(
          decoration: BoxDecoration(
            color: context.customColors.containerColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: context.colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: NoteCard(note: note, projectName: projectName),
          ),
        ),
      ),
    );
  }
}
