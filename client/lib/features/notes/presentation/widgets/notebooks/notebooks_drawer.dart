import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/presentation/extensions/bottom_sheet_extension.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/theme/tokens.dart';
import 'package:ink/features/notes/domain/constants.dart';
import 'package:ink/features/notes/presentation/notifiers/notebooks_notifier.dart';
import 'package:ink/features/notes/presentation/widgets/notebooks/create_notebook_sheet.dart';
import 'package:ink/features/notes/presentation/widgets/notebooks/drawer_notebook_item.dart';
import 'package:ink/features/notes/presentation/widgets/notebooks/drawer_virtual_notebook_item.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';

class NotebooksDrawer extends ConsumerWidget {
  const NotebooksDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notebooks = ref.watch(notebooksProvider).value ?? [];

    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainer,
        borderRadius: const BorderRadius.horizontal(
          right: Radius.circular(AppRadius.sheet),
        ),
        boxShadow: [
          BoxShadow(
            color: context.ink.scrim,
            blurRadius: 20,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.xl,
                right: AppSpacing.xl,
                top: AppSpacing.xl,
                bottom: AppSpacing.sm,
              ),
              child: Text(
                context.t.notebook.title,
                style: context.textTheme.titleLarge,
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            // All notes first, because it is the default view and, until this
            // row existed, the only way out of a notebook was to switch tabs.
            DrawerVirtualNotebookItem(
              id: allNotebooksId,
              count: null,
              title: context.t.notes.all,
              icon: 'book',
              color: context.colorScheme.primary,
            ),

            DrawerVirtualNotebookItem(
              id: todayNotebookId,
              count: null,
              title: context.t.notes.today,
              icon: 'target',
              color: context.colorScheme.primary,
            ),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.md,
              ),
              child: Divider(height: 1, color: context.theme.dividerColor),
            ),

            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: notebooks.length,
                itemBuilder: (_, i) {
                  return DrawerNotebookItem(
                    notebook: notebooks[i],
                    count: null,
                  );
                },
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.sm,
              ),
              child: Divider(height: 1, color: context.theme.dividerColor),
            ),

            Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.md,
                right: AppSpacing.md,
                top: AppSpacing.xs,
                bottom: AppSpacing.lg,
              ),
              child: TextButton.icon(
                onPressed: () => context.showAppBottomSheetLayout<void>(
                  child: const CreateNotebookSheet(),
                ),
                icon: const Icon(Icons.add_box_outlined, size: 20),
                label: Text(context.t.notebook.create),
                style: TextButton.styleFrom(
                  foregroundColor: context.colorScheme.primary,
                  textStyle: context.textTheme.titleMedium?.copyWith(
                    color: context.colorScheme.primary,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.md,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
