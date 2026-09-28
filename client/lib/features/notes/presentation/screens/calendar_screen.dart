import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/presentation/extensions/bottom_sheet_extension.dart';
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
  String _filterLabel(List<Project> allProjects, String selectedProjectId) {
    if (selectedProjectId == allProjectsId) return context.t.calendar.filter;

    final list = allProjects
        .where((p) => p.id == selectedProjectId)
        .firstOrNull;

    return list?.title ?? context.t.calendar.filter;
  }

  Future<void> _openViewModePicker() async {
    await context.showAppBottomSheetLayout<void>(child: const ViewModeSheet());
  }

  Future<void> _openFilterSheet() async {
    await context.showAppBottomSheetLayout<void>(
      child: const ListFilterSheet(),
    );
  }

  Future<void> _openAddTaskSheet() => const NoteNewRoute().push<void>(context);

  @override
  Widget build(BuildContext context) {
    final allLists = ref.watch(projectsProvider).value ?? [];

    final selectedProjectId = ref.watch(selectedProjectIdProvider);
    final showDescription = ref.watch(showDescriptionProvider);
    final viewMode = ref.watch(calendarViewModeStateProvider);

    final isFilterActive = selectedProjectId != allProjectsId;
    // Resolved once so the semantic label and the visible text cannot drift.
    final filterLabel = _filterLabel(allLists, selectedProjectId);

    return Scaffold(
      backgroundColor: context.colorScheme.surfaceContainer,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(
                          viewMode.icon,
                          size: AppSize.iconLarge,
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
                      // Was a bare GestureDetector: no focus, no ripple, and
                      // no semantic role, so a screen reader saw an unlabelled
                      // box where the only way to change the notebook filter
                      // lived.
                      Semantics(
                        button: true,
                        label: filterLabel,
                        excludeSemantics: true,
                        child: InkWell(
                          onTap: _openFilterSheet,
                          borderRadius: AppRadius.lgRadius,
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
                                  filterLabel,
                                  style: context.textTheme.labelMedium
                                      ?.copyWith(
                                        color: isFilterActive
                                            ? context.colorScheme.primary
                                            : context
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                      ),
                                ),
                                if (isFilterActive) ...[
                                  const SizedBox(width: AppSpacing.xs),
                                  Icon(
                                    Icons.close,
                                    size: AppSize.iconSmall,
                                    color: context.colorScheme.primary,
                                  ),
                                ],
                              ],
                            ),
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
                              size: AppSize.iconLarge,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                  ),
                  child: viewMode == CalendarViewMode.day
                      ? const DayHeader()
                      : const CalendarCard(),
                ),

                const SizedBox(height: AppSpacing.lg),

                // The journal rows sat flush to both screen edges while the
                // calendar directly above them was inset, so the same note
                // read as a full-bleed band in one place and a card in the
                // other. Matched to the grid's own margin so the column reads
                // as one edge.
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                    child: JournalDayList(),
                  ),
                ),
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
        child: const Icon(Icons.add, size: AppSize.iconXLarge),
      ),
    );
  }
}
