import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/presentation/extensions/bottom_sheet_extension.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/theme/tokens.dart';
import 'package:ink/features/notes/domain/constants.dart';
import 'package:ink/features/notes/domain/entities/notebook.dart';
import 'package:ink/features/notes/presentation/helpers.dart';
import 'package:ink/features/notes/presentation/notifiers/notebooks_notifier.dart';
import 'package:ink/features/notes/presentation/notifiers/ui_state.dart';
import 'package:ink/features/notes/presentation/widgets/notebooks/create_notebook_sheet.dart';
import 'package:ink/features/notes/presentation/widgets/notebooks/notebook_item.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';

class DrawerNotebookItem extends ConsumerWidget {
  const DrawerNotebookItem({
    required this.notebook,
    required this.count,
    super.key,
  });

  final Notebook notebook;
  final int? count;

  Future<void> _openEditNotebook(BuildContext context) async {
    await context.showAppBottomSheetLayout<void>(
      child: CreateNotebookSheet(initialNotebook: notebook),
    );
  }

  Future<void> _deleteNotebook(BuildContext context, WidgetRef ref) async {
    final confirmed = await confirmDeletion(
      context,
      context.t.notebook.delete.title,
      context.t.notebook.delete.message,
    );

    if (confirmed) {
      await ref.read(notebooksProvider.notifier).deleteNotebook(notebook);

      if (ref.read(selectedNotebookIdProvider) == notebook.id) {
        // All notes is the landing view, so it is the honest place to land
        // when the notebook you were reading no longer exists. It also avoids
        // the title lookup throwing on a deleted id.
        ref.read(selectedNotebookIdProvider.notifier).id = allNotebooksId;
      }
    }
  }

  Future<void> _showContextMenu(BuildContext context, WidgetRef ref) async {
    final renderBox = context.findRenderObject()! as RenderBox;
    final overlay =
        Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;
    final offset = renderBox.localToGlobal(
      Offset(renderBox.size.width - 8, renderBox.size.height / 2),
      ancestor: overlay,
    );

    final position = RelativeRect.fromLTRB(
      offset.dx,
      offset.dy - 20,
      overlay.size.width - offset.dx,
      overlay.size.height - offset.dy,
    );

    await showMenu<String>(
      context: context,
      position: position,
      elevation: 6,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdRadius),
      items: [
        PopupMenuItem<String>(
          value: 'edit',
          child: Row(
            children: [
              Icon(
                Icons.edit_outlined,
                size: AppSize.iconMedium,
                color: context.colorScheme.onSurface,
              ),

              const SizedBox(width: AppSpacing.md),

              Text(
                context.t.notebook.edit,
                style: context.textTheme.titleMedium,
              ),
            ],
          ),
        ),

        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(
                Icons.delete_outline,
                size: AppSize.iconMedium,
                color: context.colorScheme.error,
              ),

              const SizedBox(width: AppSpacing.md),

              Text(
                context.t.notebook.delete.tooltip,
                style: context.textTheme.titleMedium?.copyWith(
                  color: context.colorScheme.error,
                ),
              ),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (!context.mounted) return;

      if (value == 'edit') unawaited(_openEditNotebook(context));
      if (value == 'delete') unawaited(_deleteNotebook(context, ref));
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NotebookItem(
      title: notebook.title,
      icon: notebook.emoji,
      color: Color(notebook.colorValue),
      onTap: () =>
          ref.read(selectedNotebookIdProvider.notifier).id = notebook.id,
      onLongPress: () => _showContextMenu(context, ref),
      isSelected: ref.watch(selectedNotebookIdProvider) == notebook.id,
      count: count,
    );
  }
}
