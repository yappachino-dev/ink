import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ink/app/navigation/widgets/app_bottom_nav.dart';
import 'package:ink/core/presentation/app_sizes.dart' as sizes;
import 'package:ink/core/presentation/extensions/bottom_sheet_extension.dart';
import 'package:ink/core/presentation/navigation/app_destinations.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/theme/tokens.dart';
import 'package:ink/core/presentation/widgets/app_logo.dart';
import 'package:ink/features/notes/domain/calendar_view_mode.dart';
import 'package:ink/features/notes/domain/constants.dart';
import 'package:ink/features/notes/domain/entities/project.dart';
import 'package:ink/features/notes/presentation/extensions/calendar_view_mode_ui_extension.dart';
import 'package:ink/features/notes/presentation/notifiers/projects_notifier.dart';
import 'package:ink/features/notes/presentation/notifiers/providers/calendar_notes_provider.dart';
import 'package:ink/features/notes/presentation/notifiers/ui_state.dart';
import 'package:ink/features/notes/presentation/widgets/calendar/calendar_card.dart';
import 'package:ink/features/notes/presentation/widgets/calendar/day_header.dart';
import 'package:ink/features/notes/presentation/widgets/calendar/list_filter_sheet.dart';
import 'package:ink/features/notes/presentation/widgets/calendar/task_list_view.dart';
import 'package:ink/features/notes/presentation/widgets/calendar/view_mode_sheet.dart';
import 'package:ink/features/notes/presentation/widgets/notes/editor/note_editor_sheet.dart';
import 'package:ink/i18n/strings.g.dart';

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

  Future<void> _openAddTaskSheet() async {
    await context.showAppBottomSheetLayout<void>(
      child: const NoteEditorSheet(),
    );
  }

  void _onDestinationSelected(int index) {
    switch (index) {
      case 0:
        if (ref.read(selectedProjectIdProvider) == allProjectsId) {
          ref.read(selectedProjectIdProvider.notifier).id = todayProjectId;
        }
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

    final calendarNotes = ref.watch(calendarNotesProvider);

    final selectedProjectId = ref.watch(selectedProjectIdProvider);
    final showDescription = ref.watch(showDescriptionProvider);
    final viewMode = ref.watch(calendarViewModeStateProvider);

    final isFilterActive = selectedProjectId != allProjectsId;

    return Scaffold(
      backgroundColor: context.colorScheme.surfaceContainer,
      body: SafeArea(
        child: Stack(
          children: [
            if (calendarNotes.isEmpty)
              Positioned.fill(
                bottom: 110,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(
                      sigmaX: AppEffects.blurSm,
                      sigmaY: AppEffects.blurSm,
                    ),
                    child: const Opacity(
                      opacity: 0.25,
                      child: AppLogo(size: LogoSize.large),
                    ),
                  ),
                ),
              ),

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

                      if (isFilterActive)
                        GestureDetector(
                          onTap: _openFilterSheet,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: context.ink.highlight,
                              borderRadius: AppRadius.lgRadius,
                              border: Border.all(
                                color: context.colorScheme.primary,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _filterLabel(allLists, selectedProjectId),
                                  style: Theme.of(context).textTheme.labelMedium
                                      ?.copyWith(
                                        color: context.colorScheme.primary,
                                      ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.close,
                                  size: sizes.iconSmall,
                                  color: context.colorScheme.primary,
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        const SizedBox.shrink(),

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

                Expanded(
                  child: calendarNotes.isNotEmpty
                      ? const TaskListView()
                      : const SizedBox.shrink(),
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
        child: const Icon(Icons.add, size: sizes.iconXLarge),
      ),
      bottomNavigationBar: AppBottomNav(
        onDestinationSelected: _onDestinationSelected,
      ),
    );
  }
}
