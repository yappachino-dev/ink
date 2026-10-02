import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/presentation/extensions/bottom_sheet_extension.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/theme/tokens.dart';
import 'package:ink/core/presentation/widgets/app_fab.dart';
import 'package:ink/features/notes/domain/calendar_view_mode.dart';
import 'package:ink/features/notes/presentation/extensions/calendar_view_mode_ui_extension.dart';
import 'package:ink/features/notes/presentation/navigation/notes_routes.dart';
import 'package:ink/features/notes/presentation/notifiers/ui_state.dart';
import 'package:ink/features/notes/presentation/widgets/calendar/calendar_card.dart';
import 'package:ink/features/notes/presentation/widgets/calendar/day_header.dart';
import 'package:ink/features/notes/presentation/widgets/calendar/journal_day_list.dart';
import 'package:ink/features/notes/presentation/widgets/calendar/view_mode_sheet.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';

/// A date index over the notes: a calendar grid with the selected day's entries
/// listed below it.
///
/// One screen, one question - when did I write this. Notebook scope used to
/// be a filter here too, which made the journal a filtered copy of Notes under
/// different chrome and forced the navigation shell to reset state on tab
/// entry. Notebooks are a Notes lens now.
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  Future<void> _openViewModePicker() async {
    await context.showAppBottomSheetLayout<void>(child: const ViewModeSheet());
  }

  Future<void> _openNewNoteSheet() => const NoteNewRoute().push<void>(context);

  @override
  Widget build(BuildContext context) {
    final showDescription = ref.watch(showDescriptionProvider);
    final viewMode = ref.watch(calendarViewModeStateProvider);

    return Scaffold(
      backgroundColor: context.colorScheme.surfaceContainer,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                children: [
                  // Grouped right rather than spread to opposite
                  // edges. The notebook pill used to occupy the middle of
                  // this row; with it gone, `spaceBetween` left two controls
                  // marooned at the far ends of an otherwise empty bar.
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      viewMode.icon,
                      size: AppSize.iconLarge,
                      color: context.colorScheme.onSurface,
                    ),
                    tooltip: viewMode.label(context.t),
                    onPressed: _openViewModePicker,
                  ),
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
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: viewMode == CalendarViewMode.day
                  ? const DayHeader()
                  : const CalendarCard(),
            ),
            const SizedBox(height: AppSpacing.lg),
            // The journal rows sat flush to both screen edges while the
            // calendar directly above them was inset, so the same note read as
            // full-bleed band in one place and a card in the other. Matched to
            // the grid's own margin so the column reads as one edge.
            const Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: JournalDayList(),
              ),
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
