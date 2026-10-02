import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/features/notes/domain/notes_lens.dart';
import 'package:ink/features/notes/presentation/notifiers/ui_state.dart';
import 'package:ink/features/notes/presentation/widgets/notebooks/notebook_item.dart';
import 'package:material_ui/material_ui.dart';

/// A drawer row for a built-in lens such as Today, rather than a real notebook.
///
/// A lens is not a notebook, so there is nothing to rename, recolour or
/// delete. Renaming a real notebook goes through [NotebookItem] instead.
class DrawerVirtualNotebookItem extends ConsumerWidget {
  const DrawerVirtualNotebookItem({
    required this.lens,
    required this.count,
    required this.title,
    required this.icon,
    required this.color,
    super.key,
  });

  final NotesLens lens;
  final int? count;
  final String title;
  final String icon;
  final Color color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NotebookItem(
      title: title,
      icon: icon,
      color: color,
      onTap: () => ref.read(notesLensSelectionProvider.notifier).select(lens),
      isSelected: ref.watch(notesLensSelectionProvider) == lens,
    );
  }
}
