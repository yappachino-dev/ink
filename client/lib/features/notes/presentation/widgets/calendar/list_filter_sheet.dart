import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/theme/tokens.dart';
import 'package:ink/core/presentation/widgets/bottom_sheet.dart';
import 'package:ink/features/notes/domain/constants.dart';
import 'package:ink/features/notes/presentation/notifiers/projects_notifier.dart';
import 'package:ink/features/notes/presentation/notifiers/ui_state.dart';
import 'package:ink/features/notes/presentation/widgets/projects/project_icon_view.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';

const _allProjectsIcon = 'book';

class ListFilterSheet extends ConsumerWidget {
  const ListFilterSheet({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(projectsProvider).value ?? [];
    final selectedProjectId = ref.watch(selectedProjectIdProvider);
    return BottomSheetLayout(
      padding: const EdgeInsets.only(
  left: AppSpacing.xl,
  right: AppSpacing.xl,
  top: AppSpacing.md,
  bottom: AppSpacing.lg,
),
      header: Text(context.t.note.project, style: context.textTheme.titleLarge),
      children: [
        _ProjectTile(
          title: context.t.note.allProjects,
          icon: _allProjectsIcon,
          isSelected: selectedProjectId == allProjectsId,
          onTap: () =>
              ref.read(selectedProjectIdProvider.notifier).id = allProjectsId,
        ),
        if (projects.isNotEmpty) const Divider(),
        ...projects.map(
          (project) => _ProjectTile(
            title: project.title,
            icon: project.emoji,
            isSelected: selectedProjectId == project.id,
            onTap: () =>
                ref.read(selectedProjectIdProvider.notifier).id = project.id,
          ),
        ),
      ],
    );
  }
}

class _ProjectTile extends StatelessWidget {
  const _ProjectTile({
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
      leading: ProjectIconView(value: icon),
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
