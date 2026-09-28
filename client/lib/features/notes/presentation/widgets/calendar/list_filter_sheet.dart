import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/theme/tokens.dart';
import 'package:ink/core/presentation/widgets/bottom_sheet.dart';
import 'package:ink/features/notes/domain/constants.dart';
import 'package:ink/features/notes/presentation/notifiers/notebooks_notifier.dart';
import 'package:ink/features/notes/presentation/notifiers/ui_state.dart';
import 'package:ink/features/notes/presentation/widgets/notebooks/notebook_icon_view.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';

const _allNotebooksIcon = 'book';

class ListFilterSheet extends ConsumerWidget {
  const ListFilterSheet({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notebooks = ref.watch(notebooksProvider).value ?? [];
    final selectedNotebookId = ref.watch(selectedNotebookIdProvider);
    return BottomSheetLayout(
      padding: AppSpacing.sheetRows,
      header: Text(
        context.t.note.notebook,
        style: context.textTheme.titleLarge,
      ),
      children: [
        _NotebookTile(
          title: context.t.note.allNotebooks,
          icon: _allNotebooksIcon,
          isSelected: selectedNotebookId == allNotebooksId,
          onTap: () =>
              ref.read(selectedNotebookIdProvider.notifier).id = allNotebooksId,
        ),
        if (notebooks.isNotEmpty) const Divider(),
        ...notebooks.map(
          (notebook) => _NotebookTile(
            title: notebook.title,
            icon: notebook.emoji,
            isSelected: selectedNotebookId == notebook.id,
            onTap: () =>
                ref.read(selectedNotebookIdProvider.notifier).id = notebook.id,
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
