
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ink/app/navigation/widgets/app_bottom_nav.dart';
import 'package:ink/core/presentation/app_sizes.dart' as sizes;
import 'package:ink/core/presentation/extensions/bottom_sheet_extension.dart';
import 'package:ink/core/presentation/navigation/app_destinations.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/theme/tokens.dart';
import 'package:ink/features/notes/domain/calendar_view_mode.dart';
import 'package:ink/features/notes/domain/constants.dart';
import 'package:ink/features/notes/domain/entities/project.dart';
import 'package:ink/features/notes/presentation/extensions/calendar_view_mode_ui_extension.dart';
import 'package:ink/features/notes/presentation/navigation/notes_routes.dart';
import 'package:ink/features/notes/presentation/notifiers/projects_notifier.dart';
import 'package:ink/features/notes/presentation/notifiers/ui_state.dart';
import 'package:ink/features/notes/presentation/widgets/calendar/calendar_card.dart';
import 'package:ink/features/notes/presentation/widgets/calendar/day_header.dart';
import 'package:ink/features/notes/presentation/widgets/calendar/journal_day_list.dart';
import 'package:ink/features/notes/presentation/widgets/calendar/list_filter_sheet.dart';
import 'package:ink/features/notes/presentation/widgets/calendar/view_mode_sheet.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  String _filterLabel(
    List<Project> allProjects,
    String selectedProjectId,
  ) {
    if (selectedProjectId == allProjectsId) return context.t.calendar.filter;

    final list = allProjects
        .where((p) => p.id == selectedProjectId)
        .firstOrNull;

    return list?.title ?? context.t.calendar.filter;
  }

  Future<void> _openViewModePicker() async {
    await context.showAppBottomSheetLayout<void>(
      child: const ViewModeSheet(),
    );
  }

  Future<void> _openFilterSheet() async {
    await context.showAppBottomSheetLayout<void>(
      child: const ListFilterSheet(),
    );
  }

  Future<void> _openAddTaskSheet() =>
      const NoteNewRoute().push<void>(context);

  void _onDestinationSelected(int index) {
    switch (index) {
      case 0:
        // See the matching note in `home_screen.dart`: All notes is a real Home
        // lens now, so returning from the calendar must not reset the lens.
        context.go(AppDestinations.notes);
      case 1:
        ref.read(selectedProjectIdProvider.notifier).id = allProjectsId;
        context.go(AppDestinations.calendar);
      case 2:
        context.go(AppDestinations.profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final allLists = ref.watch(projectsProvider).value ?? [];

    final selectedProjectId = ref.watch(selectedProjectIdProvider);
    final showDescription = ref.watch(showDescriptionProvider);
    final viewMode = ref.watch(calendarViewModeStateProvider);

    final isFilterActive = selectedProjectId != allProjectsId;

    return Scaffold(
      backgroundColor: context.colorScheme.surfaceContainer,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(
                          viewMode.icon,
                          size: sizes.iconLarge,
                          color: context.colorScheme.onSurface,
                        ),
                        tooltip: viewMode.label(t),
                        onPressed: _openViewModePicker,
                      ),

                      // Always rendered. This used to be hidden when no
                      // notebook filter was applied, on the assumption that the
                      // app never started in the unfiltered state — which was
                      // true only because the default lens was Today. Now that
                      // All notes is the landing view, hiding it made the
                      // notebook filter unreachable: the guard wrapped the tap
                      // target, not just the styling. It also left
                      // [_filterLabel]'s unfiltered branch unreachable, so
                      // "Filter" was a string the user could never see.
                      GestureDetector(
                        onTap: _openFilterSheet,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isFilterActive
                                ? context.ink.highlight
                                : Colors.transparent,
                            borderRadius: AppRadius.lgRadius,
                            border: Border.all(
                              color: isFilterActive
                                  ? context.colorScheme.primary
                                  : context.colorScheme.outlineVariant,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _filterLabel(allLists, selectedProjectId),
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(
                                      color: isFilterActive
                                          ? context.colorScheme.primary
                                          : context
                                                .colorScheme
                                                .onSurfaceVariant,
                                    ),
                              ),
                              if (isFilterActive) ...[
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.close,
                                  size: sizes.iconSmall,
                                  color: context.colorScheme.primary,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              showDescription
                                  ? Icons.subject_rounded
                                  : Icons.short_text_rounded,
                              color: showDescription
                                  ? context.colorScheme.onSurface
                                  : context.colorScheme.primary,
                            ),
                            tooltip: showDescription
                                ? context.t.note.hideDetails
                                : context.t.note.showDetails,
                            onPressed: ref
                                .read(showDescriptionProvider.notifier)
                                .toggle,
                          ),

                          IconButton(
                            icon: Icon(
                              Icons.filter_alt_outlined,
                              size: sizes.iconLarge,
                              color: isFilterActive
                                  ? context.colorScheme.primary
                                  : context.colorScheme.onSurface,
                            ),
                            tooltip: context.t.calendar.filter,
                            onPressed: _openFilterSheet,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: viewMode == CalendarViewMode.day
                      ? const DayHeader()
                      : const CalendarCard(),
                ),

                const SizedBox(height: 16),

                const Expanded(child: JournalDayList()),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddTaskSheet,
        backgroundColor: context.colorScheme.primary,
        foregroundColor: context.colorScheme.surface,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: sizes.iconXLarge),
      ),
      bottomNavigationBar: AppBottomNav(
        onDestinationSelected: _onDestinationSelected,
      ),
    );
  }
}
