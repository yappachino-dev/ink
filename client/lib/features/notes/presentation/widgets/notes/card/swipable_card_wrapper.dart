import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/theme/tokens.dart';
import 'package:ink/features/notes/domain/entities/note.dart';
import 'package:ink/features/notes/presentation/helpers.dart';
import 'package:ink/features/notes/presentation/notifiers/notes_notifier.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';

class SwipableCardWrapper extends ConsumerWidget {
  const SwipableCardWrapper({
    required this.note,
    required this.child,
    super.key,
  });

  final Note note;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey(
        'dismissable-${note.isCompleted ? 'completed-' : ''}note-${note.id}',
      ),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.xl),
        decoration: BoxDecoration(
          color: context.colorScheme.onError,
          borderRadius: AppRadius.mdRadius,
        ),
        child: Icon(
          Icons.delete_outline,
          size: AppSize.iconLarge,
          color: context.colorScheme.error,
        ),
      ),
      confirmDismiss: (_) => confirmDeletion(
        context,
        context.t.note.delete.title,
        context.t.note.delete.message,
      ),
      onDismissed: (_) => ref.read(notesProvider.notifier).deleteNote(note),
      child: child,
    );
  }
}
