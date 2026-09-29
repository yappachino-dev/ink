import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/presentation/extensions/bottom_sheet_extension.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/theme/tokens.dart';
import 'package:ink/core/presentation/widgets/app_fab.dart';
import 'package:ink/features/notes/domain/calendar_view_mode.dart';
import 'package:ink/features/notes/domain/constants.dart';
import 'package:ink/features/notes/domain/entities/notebook.dart';
import 'package:ink/features/notes/presentation/extensions/calendar_view_mode_ui_extension.dart';
import 'package:ink/features/notes/presentation/navigation/notes_routes.dart';
import 'package:ink/features/notes/presentation/notifiers/notebooks_notifier.dart';
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
  String _filterLabel(List<Notebook> allNotebooks, String selectedNotebookId) {
    if (selectedNotebookId == allNotebooksId) return context.t.calendar.filter;

    final list = allNotebooks
        .where((p) => p.id == selectedNotebookId)
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

  Future<void> _openNewNoteSheet() => const NoteNewRoute().push<void>(context);

  /// Drops the notebook filter and returns to the All notes lens.
  ///
  /// Clears to `allNotebooksId` rather than to null, because that is the id
  /// the rest of the app still treats as "no filter". A `todayNotebookId` lens
  /// is included: the pill's x means "stop filtering", and a due-date lens is a
  /// filter too, so leaving it applied would make the x look inert.
  void _clearFilter() {
    ref.read(selectedNotebookIdProvider.notifier).id = allNotebooksId;
  }

  @override
  Widget build(BuildContext context) {
    final allLists = ref.watch(notebooksProvider).value ?? [];

    final selectedNotebookId = ref.watch(selectedNotebookIdProvider);
    final showDescription = ref.watch(showDescriptionProvider);
    final viewMode = ref.watch(calendarViewModeStateProvider);

    final isFilterActive = selectedNotebookId != allNotebooksId;
    // Resolved once so the semantic label and the visible text cannot drift.
    final filterLabel = _filterLabel(allLists, selectedNotebookId);

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
                      // app never started in the unfiltered state - which was
                      // true only because the default lens was Today. Now that
                      // All notes is the landing view, hiding it made the
                      // notebook filter unreachable: the guard wrapped the tap
                      // target, not just the styling. It also left
                      // [_filterLabel]'s unfiltered branch unreachable, so
                      // "Filter" was a string the user could never see.
                      //
                      // Two sibling nodes, not one node with a decoration.
                      //
                      // The x used to be an Icon inside the same InkWell as the
                      // label, so tapping it opened the picker rather than
                      // clearing the filter - the opposite of what an x means
                      // on a chip anywhere else. It was also nested under
                      // `excludeSemantics: true`, so a screen reader was told
                      // there was one button and had no way to learn that half
                      // of it did something else.
                      //
                      // Each region is therefore its own InkWell with its own
                      // Semantics label, and the shared pill decoration is
                      // carried by the Container around both. The label region
                      // keeps `excludeSemantics` so the Text does not announce
                      // itself twice alongside the button's label.
                      // `Material`, not `Container`. The border is rounded but
                      // nothing clipped the ink, so the ripple from the label
                      // ran square over the rounded corners, and the x's
                      // ripple did it on the right-hand edge where the
                      // rounding is most visible. `clipBehavior` is what fixes
                      // it; a `BorderRadius` on a decoration alone does not
                      // clip.
                      Material(
                        color: isFilterActive
                            ? context.ink.highlight
                            : Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.lgRadius,
                          side: BorderSide(
                            color: isFilterActive
                                ? context.colorScheme.primary
                                : context.colorScheme.outlineVariant,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Semantics(
                              button: true,
                              label: filterLabel,
                              excludeSemantics: true,
                              child: InkWell(
                                onTap: _openFilterSheet,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  child: Text(
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
                                ),
                              ),
                            ),
                            if (isFilterActive)
                              // A 16dp icon in 6dp of padding is a ~28dp
                              // target: below the 48dp Material floor and
                              // narrow enough that a miss lands on the label
                              // and opens the picker instead, which is the
                              // defect this replaced. The height is what makes
                              // the pill readable as a control; the width keeps
                              // the x from crowding the label.
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  minWidth: AppSize.touchTarget,
                                  minHeight: AppSize.touchTarget,
                                ),
                                child: Semantics(
                                  button: true,
                                  label: context.t.note.clearNotebookFilter,
                                  child: InkWell(
                                    onTap: _clearFilter,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.sm,
                                      ),
                                      child: Icon(
                                        Icons.close,
                                        size: AppSize.iconSmall,
                                        color: context.colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
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
      // The same widget and the same location as Notes. These were two
      // hand-built buttons whose insets differed by 4px, so the button jumped
      // when switching tabs; the elevation differed too.
      floatingActionButtonLocation: const AppFabLocation(),
      floatingActionButton: AppFab(onPressed: _openNewNoteSheet),
    );
  }
}
