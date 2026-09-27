import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/theme/tokens.dart';
import 'package:ink/core/presentation/widgets/bottom_sheet.dart';
import 'package:ink/features/notes/presentation/helpers.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';

class ReminderPickerSheet extends StatelessWidget {
  const ReminderPickerSheet({
    required this.current,
    required this.onSelected,
    super.key,
  });

  final int? current;
  final ValueChanged<int?> onSelected;

  static const List<int?> _options = [null, 0, 10, 30, 60, 1440];

  @override
  Widget build(BuildContext context) {
    return BottomSheetLayout(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
      header: Text(
        context.t.note.reminder.select,
        style: context.textTheme.titleLarge,
      ),
      children: [
        ..._options.map(
          (opt) => _ReminderTile(
            option: opt,
            isSelected: opt == current,
            onTap: () => onSelected(opt),
          ),
        ),
      ],
    );
  }
}

class _ReminderTile extends StatelessWidget {
  const _ReminderTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final int? option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        option == null
            ? Icons.notifications_off_outlined
            : Icons.notifications_outlined,
        size: AppSize.iconLarge,
        color: isSelected
            ? context.colorScheme.primary
            : context.theme.hintColor,
      ),
      title: Text(
        option == null
            ? context.t.note.reminder.none
            : reminderLabel(option!, context.t),
        style: context.textTheme.titleMedium?.copyWith(
          color: isSelected
              ? context.colorScheme.primary
              : context.colorScheme.onSurface,
        ),
      ),
      trailing: isSelected
          ? Icon(
              Icons.check,
              size: AppSize.iconMedium,
              color: context.colorScheme.primary,
            )
          : null,
      onTap: onTap,
    );
  }
}
