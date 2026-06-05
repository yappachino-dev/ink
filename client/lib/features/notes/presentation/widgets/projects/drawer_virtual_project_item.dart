import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/presentation/app_sizes.dart' as sizes;
import 'package:ink/core/presentation/extensions/bottom_sheet_extension.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/features/notes/domain/constants.dart';
import 'package:ink/features/notes/presentation/notifiers/ui_state.dart';
import 'package:ink/features/notes/presentation/widgets/projects/create_project_sheet.dart';
import 'package:ink/features/notes/presentation/widgets/projects/project_item.dart';
import 'package:ink/i18n/strings.g.dart';

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

  Future<void> _openEditList(BuildContext context) async {
    final isInbox = id == inboxProjectId;

    await context.showAppBottomSheetLayout<void>(
      child: CreateProjectSheet(colorOnly: isInbox),
    );
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      items: [
        if (id == inboxProjectId)
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
      ],
    ).then((value) {
      if (!context.mounted) return;

      if (value == 'edit') unawaited(_openEditList(context));
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProjectItem(
      title: title,
      emoji: emoji,
      color: color,
      onTap: () => ref.read(selectedProjectIdProvider.notifier).set(id),
      onLongPress: () =>
          id == todayProjectId ? null : _showContextMenu(context, ref),
      isSelected: ref.watch(selectedProjectIdProvider) == id,
    );
  }
}
