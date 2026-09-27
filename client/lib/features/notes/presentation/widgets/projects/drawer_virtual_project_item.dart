import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/features/notes/presentation/notifiers/ui_state.dart';
import 'package:ink/features/notes/presentation/widgets/projects/project_item.dart';
import 'package:material_ui/material_ui.dart';

/// A drawer row for a built-in lens such as Today, rather than a real notebook.
///
/// These ids are sentinels from `domain/constants.dart`, not project rows, so
/// there is nothing to rename, recolour, or delete. Renaming a real notebook
/// goes through [ProjectItem] instead.
class DrawerVirtualProjectItem extends ConsumerWidget {
  const DrawerVirtualProjectItem({
    required this.id,
    required this.count,
    required this.title,
    required this.emoji,
    required this.color,
    super.key,
  });

  final String id;
  final int? count;
  final String title;
  final String emoji;
  final Color color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProjectItem(
      title: title,
      emoji: emoji,
      color: color,
      onTap: () => ref.read(selectedProjectIdProvider.notifier).id = id,
      isSelected: ref.watch(selectedProjectIdProvider) == id,
    );
  }
}
