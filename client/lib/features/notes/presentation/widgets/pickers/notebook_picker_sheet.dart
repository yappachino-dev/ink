import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/theme/tokens.dart';
import 'package:ink/core/presentation/widgets/bottom_sheet.dart';
import 'package:ink/features/notes/domain/entities/notebook.dart';
import 'package:ink/features/notes/presentation/widgets/notebooks/notebook_icon_view.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';

class NotebookPickerSheet extends StatelessWidget {
  const NotebookPickerSheet({
    required this.notebooks,
    required this.selectedNotebookId,
    required this.onSelected,
    super.key,
  });
  final List<Notebook> notebooks;
  final String? selectedNotebookId;
  final ValueChanged<String?> onSelected;
  @override
  Widget build(BuildContext context) {
    return BottomSheetLayout(
      padding: AppSpacing.sheetRows,
      header: Text(
        context.t.notebook.select,
        style: context.textTheme.titleLarge,
      ),
      children: [
        _NotebookTile(
          title: context.t.notebook.none,
          icon: 'book',
          isSelected: selectedNotebookId == null,
          onTap: () => onSelected(null),
        ),
        if (notebooks.isNotEmpty) Divider(color: context.theme.dividerColor),
        ...notebooks.map(
          (notebook) => _NotebookTile(
            title: notebook.title,
            icon: notebook.emoji,
            isSelected: selectedNotebookId == notebook.id,
            onTap: () => onSelected(notebook.id),
          ),
        ),
      ],
    );
  }
}

class _NotebookTile extends StatelessWidget {
  const _NotebookTile({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });
  final String title;
  final String icon;
  final bool isSelected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: NotebookIconView(value: icon),
      title: Text(
        title,
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
