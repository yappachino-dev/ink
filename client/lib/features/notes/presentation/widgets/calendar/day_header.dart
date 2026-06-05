import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/presentation/app_sizes.dart' as sizes;
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/features/notes/presentation/notifiers/ui_state.dart';
import 'package:ink/i18n/strings.g.dart';

class DayHeader extends ConsumerWidget {
  const DayHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(calendarSelectedDateProvider);
    final title = _formatDayTitle(selectedDate, context.t);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              ref
                  .read(calendarSelectedDateProvider.notifier)
                  .setDate(selectedDate.subtract(const Duration(days: 1)));
              ref
                  .read(calendarFocusedDateProvider.notifier)
                  .setDate(selectedDate.subtract(const Duration(days: 1)));
            },
            child: Icon(
              Icons.chevron_left,
              size: sizes.iconMedium,
              color: context.theme.hintColor,
            ),
          ),

          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: context.textTheme.titleMedium,
            ),
          ),

          GestureDetector(
            onTap: () {
              ref
                  .read(calendarSelectedDateProvider.notifier)
                  .setDate(selectedDate.add(const Duration(days: 1)));
              ref
                  .read(calendarFocusedDateProvider.notifier)
                  .setDate(selectedDate.add(const Duration(days: 1)));
            },
            child: Icon(
              Icons.chevron_right,
              size: sizes.iconMedium,
              color: context.theme.hintColor,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDayTitle(DateTime date, Translations t) {
  return '${date.day} ${t.calendar.months[date.month - 1]} ${date.year}';
}
