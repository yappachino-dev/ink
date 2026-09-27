import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/theme/tokens.dart';
import 'package:ink/core/presentation/widgets/bottom_sheet.dart';
import 'package:ink/features/notes/domain/entities/project.dart';
import 'package:ink/features/notes/presentation/widgets/projects/project_icon_view.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';

class ProjectPickerSheet extends StatelessWidget {
  const ProjectPickerSheet({
    required this.projects,
    required this.selectedProjectId,
    required this.onSelected,
    super.key,
  });
  final List<Project> projects;
  final String? selectedProjectId;
  final ValueChanged<String?> onSelected;
  @override
  Widget build(BuildContext context) {
    return BottomSheetLayout(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
      header: Text(
        context.t.project.select,
        style: context.textTheme.titleLarge,
      ),
      children: [
        _ProjectTile(
          title: context.t.project.none,
          icon: 'book',
          isSelected: selectedProjectId == null,
          onTap: () => onSelected(null),
        ),
        if (projects.isNotEmpty) Divider(color: context.theme.dividerColor),
        ...projects.map(
          (project) => _ProjectTile(
            title: project.title,
            icon: project.emoji,
            isSelected: selectedProjectId == project.id,
            onTap: () => onSelected(project.id),
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
