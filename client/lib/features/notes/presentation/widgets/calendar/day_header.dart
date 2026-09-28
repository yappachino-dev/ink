import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/theme/tokens.dart';
import 'package:ink/features/notes/presentation/notifiers/ui_state.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';

class DayHeader extends ConsumerWidget {
  const DayHeader({super.key});

  void _step(BuildContext context, WidgetRef ref, int days) {
    final current = ref.read(calendarSelectedDateProvider);

    // Calendar arithmetic, not `add(Duration(days: days))`.
    //
    // The provider is seeded from `DateTime.now()`, so this value carries a
    // real time of day, and `Duration(days: 1)` is exactly 24 hours. On a
    // daylight-saving boundary that is not one day: in America/New_York, a
    // 00:30 on 1 Nov 2026 (a 25-hour day) plus 24 hours is 23:30 the *same*
    // day, so the button did nothing; and 23:30 on 7 Mar 2026 (a 23-hour day)
    // plus 24 hours is 00:30 on the 9th, so it skipped a day. Both cases
    // behave under UTC, which is why a UTC test runner never saw it.
    //
    // The result is midnight, so the state becomes a canonical date. Every
    // consumer treats it as one - `isSameDay` in the journal query, `.day` in
    // the header and the grid - so nothing reads the time, and a canonical
    // value is comparable with `==` and cannot drift again.
    final next = DateTime(current.year, current.month, current.day + days);

    ref.read(calendarSelectedDateProvider.notifier).date = next;
    ref.read(calendarFocusedDateProvider.notifier).date = next;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(calendarSelectedDateProvider);
    final title = _formatDayTitle(selectedDate, context.t);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainer,
        borderRadius: AppRadius.lgRadius,
      ),
      child: Row(
        children: [
          // Icon-only, so the tooltip is the accessible name. A bare
          // GestureDetector here announced as an unlabelled button and had no
          // ripple or keyboard focus.
          IconButton(
            onPressed: () => _step(context, ref, -1),
            icon: const Icon(Icons.chevron_left, size: AppSize.iconMedium),
            color: context.theme.hintColor,
            tooltip: context.t.calendar.previousDay,
            visualDensity: VisualDensity.compact,
          ),

          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: context.textTheme.titleMedium,
            ),
          ),

          IconButton(
            onPressed: () => _step(context, ref, 1),
            icon: const Icon(Icons.chevron_right, size: AppSize.iconMedium),
            color: context.theme.hintColor,
            tooltip: context.t.calendar.nextDay,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

String _formatDayTitle(DateTime date, Translations t) {
  return '${date.day} ${t.calendar.months[date.month - 1]} ${date.year}';
}
