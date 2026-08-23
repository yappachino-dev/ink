import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/presentation/app_sizes.dart' as sizes;
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/features/notes/domain/calendar_view_mode.dart';
import 'package:ink/features/notes/domain/entities/note.dart';
import 'package:ink/features/notes/presentation/notifiers/notes_notifier.dart';
import 'package:ink/features/notes/presentation/notifiers/ui_state.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:ink/core/presentation/theme/tokens.dart';

class CalendarCard extends ConsumerWidget {
  const CalendarCard({super.key});

  bool hasTasksForDay(DateTime day, List<Note> notes) =>
      notes.any((n) => isSameDay(n.dueDate, day));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesProvider).value ?? {};

    final selectedDay = ref.watch(calendarSelectedDateProvider);
    final focusedDay = ref.watch(calendarFocusedDateProvider);
    final viewMode = ref.watch(calendarViewModeStateProvider);

    final textTheme = context.textTheme;

    final dayStyle = textTheme.bodyMedium.orEmpty;
    final selectedDayStyle = textTheme.bodyMedium.orEmpty.copyWith(
      color: context.colorScheme.primary,
    );
    final todayStyle = textTheme.bodyMedium.orEmpty.copyWith(
      color: context.colorScheme.primary,
    );
    final dowStyle = textTheme.labelSmall.orEmpty.copyWith(
      color: context.theme.hintColor,
    );
    final headerStyle = textTheme.titleMedium.orEmpty.copyWith(
      color: context.colorScheme.onSurface,
    );

    return Container(
      padding: const EdgeInsets.only(bottom: 12, left: 8, right: 8),
      decoration: BoxDecoration(
        color: context.ink.container,
        borderRadius: AppRadius.lgRadius,
        boxShadow: [
          BoxShadow(
            color: context.ink.shadow.withValues(alpha: AppAlpha.faint),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TableCalendar<dynamic>(
        firstDay: DateTime.utc(2020),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: focusedDay,
        calendarFormat: viewMode.calendarFormat ?? CalendarFormat.month,
        selectedDayPredicate: (day) => isSameDay(selectedDay, day),
        onDaySelected: (selected, focused) {
          ref.read(calendarSelectedDateProvider.notifier).setDate(selected);
          ref.read(calendarFocusedDateProvider.notifier).setDate(focused);
        },
        onPageChanged: (date) =>
            ref.read(calendarFocusedDateProvider.notifier).setDate(date),
        eventLoader: (day) =>
            hasTasksForDay(day, notes.values.toList()) ? [true] : [],
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleTextStyle: headerStyle,
          headerPadding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 8,
          ),
          leftChevronIcon: Icon(
            Icons.chevron_left,
            size: sizes.iconMedium,
            color: context.theme.hintColor,
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right,
            size: sizes.iconMedium,
            color: context.theme.hintColor,
          ),
          leftChevronMargin: EdgeInsets.zero,
          rightChevronMargin: EdgeInsets.zero,
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: dowStyle,
          weekendStyle: dowStyle,
        ),
        daysOfWeekHeight: 24,
        calendarStyle: CalendarStyle(
          cellMargin: const EdgeInsets.all(4),
          selectedDecoration: BoxDecoration(
            color: context.ink.highlight,
            shape: BoxShape.circle,
            border: Border.all(color: context.colorScheme.primary, width: 1.5),
          ),
          selectedTextStyle: selectedDayStyle,
          todayDecoration: const BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
          ),
          todayTextStyle: todayStyle,
          defaultTextStyle: dayStyle,
          weekendTextStyle: dayStyle,
          outsideDaysVisible: false,
          markerDecoration: BoxDecoration(
            color: context.colorScheme.primary.withValues(alpha: AppAlpha.strong),
            shape: BoxShape.circle,
          ),
          markersMaxCount: 1,
          markerSize: 5,
          markerMargin: const EdgeInsets.only(top: 1),
        ),
      ),
    );
  }
}
