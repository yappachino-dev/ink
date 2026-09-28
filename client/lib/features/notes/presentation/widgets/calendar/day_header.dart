import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/theme/tokens.dart';
import 'package:ink/features/notes/presentation/notifiers/ui_state.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';

class DayHeader extends ConsumerWidget {
  const DayHeader({super.key});

  void _step(BuildContext context, WidgetRef ref, int days) {
    // ref.read, not the ref.watch in [selectedDateOf]: this runs from an
    // onPressed callback, not from build, so a watch here would re-subscribe
    // on every tap and never dispose.
    final next = ref
        .read(calendarSelectedDateProvider)
        .add(Duration(days: days));
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
