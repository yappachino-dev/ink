import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/presentation/extensions/bottom_sheet_extension.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/theme/tokens.dart';
import 'package:ink/features/notes/domain/constants.dart';
import 'package:ink/features/notes/presentation/notifiers/projects_notifier.dart';
import 'package:ink/features/notes/presentation/widgets/projects/create_project_sheet.dart';
import 'package:ink/features/notes/presentation/widgets/projects/drawer_project_item.dart';
import 'package:ink/features/notes/presentation/widgets/projects/drawer_virtual_project_item.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';

class ProjectsDrawer extends ConsumerWidget {
  const ProjectsDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(projectsProvider).value ?? [];

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
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text(
                context.t.project.title,
                style: context.textTheme.titleLarge,
              ),
            ),

            const SizedBox(height: 8),

            // All notes first, because it is the default view and, until this
            // row existed, the only way out of a notebook was to switch tabs.
            DrawerVirtualProjectItem(
              id: allProjectsId,
              count: null,
              title: context.t.home.all,
              icon: 'book',
              color: context.colorScheme.primary,
            ),

            DrawerVirtualProjectItem(
              id: todayProjectId,
              count: null,
              title: context.t.home.today,
              icon: 'target',
              color: context.colorScheme.primary,
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Divider(height: 1, color: context.theme.dividerColor),
            ),

            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: projects.length,
                itemBuilder: (_, i) {
                  return DrawerProjectItem(project: projects[i], count: null);
                },
              ),
            ),

            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Divider(height: 1, color: context.theme.dividerColor),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
              child: TextButton.icon(
                onPressed: () => context.showAppBottomSheetLayout<void>(
                  child: const CreateProjectSheet(),
                ),
                icon: const Icon(Icons.add_box_outlined, size: 20),
                label: Text(context.t.project.create),
                style: TextButton.styleFrom(
                  foregroundColor: context.colorScheme.primary,
                  textStyle: context.textTheme.titleMedium?.copyWith(
                    color: context.colorScheme.primary,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 12,
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
