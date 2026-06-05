import 'package:flutter/material.dart';
import 'package:ink/core/presentation/app_sizes.dart' as sizes;
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/widgets/bottom_sheet.dart';
import 'package:ink/features/notes/domain/task_priority.dart';
import 'package:ink/i18n/strings.g.dart';

class PriorityPickerSheet extends StatelessWidget {
  const PriorityPickerSheet({
    required this.current,
    required this.onSelected,
    super.key,
  });

  final TaskPriority current;
  final ValueChanged<TaskPriority> onSelected;

  @override
  Widget build(BuildContext context) {
    return BottomSheetLayout(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      header: Text(
        context.t.note.priority.select,
        style: context.textTheme.titleLarge,
      ),
      children: [
        ...TaskPriority.values.map(
          (p) => _PriorityTile(
            priority: p,
            isCurrent: p == current,
            onTap: () => onSelected(p),
          ),
        ),
      ],
    );
  }
}

class _PriorityTile extends StatelessWidget {
  const _PriorityTile({
    required this.priority,
    required this.isCurrent,
    required this.onTap,
  });

  final TaskPriority priority;
  final bool isCurrent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        Icons.flag,
        size: sizes.iconLarge,
        color: priority == TaskPriority.none
            ? context.theme.hintColor
            : priority.color,
      ),
      title: Text(
        priority.label(context.t),
        style: context.textTheme.titleMedium?.copyWith(
          color: isCurrent
              ? context.colorScheme.primary
              : context.colorScheme.onSurface,
        ),
      ),
      trailing: isCurrent
          ? Icon(
              Icons.check,
              size: sizes.iconMedium,
              color: context.colorScheme.primary,
            )
          : null,
      onTap: onTap,
    );
  }
}
