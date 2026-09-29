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

  /// Applies [notebookId] and closes the sheet.
  ///
  /// Single-select with instant apply: one value, a radio-style check mark,
  /// and the write happens on tap. That makes this a value *picker*, not a
  /// multi-select filter, and a picker dismisses on selection - the result is
  /// behind the sheet, and on a phone the only feedback a user got was a check
  /// mark below the fold. Keeping it open would only matter if several values
  /// could be toggled at once, which one `selectedNotebookId` cannot express.
  ///
  /// Uniform across every row, including All notes: a picker that closes for
  /// some rows and not others is worse than either behaviour.
  void _select(BuildContext context, WidgetRef ref, String notebookId) {
    ref.read(selectedNotebookIdProvider.notifier).id = notebookId;
    Navigator.of(context).pop();
  }

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
          onTap: () => _select(context, ref, allNotebooksId),
        ),
        if (notebooks.isNotEmpty) const Divider(),
        ...notebooks.map(
          (notebook) => _NotebookTile(
            title: notebook.title,
            icon: notebook.emoji,
            isSelected: selectedNotebookId == notebook.id,
            onTap: () => _select(context, ref, notebook.id),
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
