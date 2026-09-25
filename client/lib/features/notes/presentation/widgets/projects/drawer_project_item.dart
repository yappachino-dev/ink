import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/presentation/app_sizes.dart' as sizes;
import 'package:ink/core/presentation/extensions/bottom_sheet_extension.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/theme/tokens.dart';
import 'package:ink/features/notes/domain/constants.dart';
import 'package:ink/features/notes/domain/entities/project.dart';
import 'package:ink/features/notes/presentation/helpers.dart';
import 'package:ink/features/notes/presentation/notifiers/projects_notifier.dart';
import 'package:ink/features/notes/presentation/notifiers/ui_state.dart';
import 'package:ink/features/notes/presentation/widgets/projects/create_project_sheet.dart';
import 'package:ink/features/notes/presentation/widgets/projects/project_item.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';

class DrawerProjectItem extends ConsumerWidget {
  const DrawerProjectItem({
    required this.project,
    required this.count,
    super.key,
  });

  final Project project;
  final int? count;

  Future<void> _openEditProject(BuildContext context) async {
    await context.showAppBottomSheetLayout<void>(
      child: CreateProjectSheet(initialProject: project),
    );
  }

  Future<void> _deleteProject(BuildContext context, WidgetRef ref) async {
    final confirmed = await confirmDeletion(
      context,
      context.t.project.delete.title,
      context.t.project.delete.message,
    );

    if (confirmed) {
      await ref.read(projectsProvider.notifier).deleteProject(project);

      if (ref.read(selectedProjectIdProvider) == project.id) {
        ref.read(selectedProjectIdProvider.notifier).id = todayProjectId;
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
                size: sizes.iconMedium,
                color: context.colorScheme.onSurface,
              ),

              const SizedBox(width: 12),

              Text(
                context.t.project.edit,
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
                size: sizes.iconMedium,
                color: context.colorScheme.error,
              ),

              const SizedBox(width: 12),

              Text(
                context.t.project.delete.tooltip,
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

      if (value == 'edit') unawaited(_openEditProject(context));
      if (value == 'delete') unawaited(_deleteProject(context, ref));
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProjectItem(
      title: project.title,
      emoji: project.emoji,
      color: Color(project.colorValue),
      onTap: () => ref.read(selectedProjectIdProvider.notifier).id = project.id,
      onLongPress: () => _showContextMenu(context, ref),
      isSelected: ref.watch(selectedProjectIdProvider) == project.id,
      count: count,
    );
  }
}
