import 'package:ink/features/notes/domain/calendar_view_mode.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';
import 'package:table_calendar/table_calendar.dart';

extension CalendarViewModeUiExtension on CalendarViewMode {
  String label(Translations t) {
    switch (this) {
      case CalendarViewMode.month:
        return t.calendar.modes.month;
      case CalendarViewMode.twoWeeks:
        return t.calendar.modes.twoWeeks;
      case CalendarViewMode.week:
        return t.calendar.modes.week;
      case CalendarViewMode.day:
        return t.calendar.modes.day;
    }
  }

  /// The icon in the calendar's app bar, which is the only standing record of
  /// which mode is active. Two-week and week used to share
  /// `calendar_view_week_outlined`, so switching between them left the header
  /// looking identical while the grid underneath changed - the icon then
  /// actively lied about the state it was supposed to convey.
  IconData get icon {
    switch (this) {
      case CalendarViewMode.month:
        return Icons.calendar_view_month_outlined;
      case CalendarViewMode.twoWeeks:
        return Icons.date_range_outlined;
      case CalendarViewMode.week:
        return Icons.calendar_view_week_outlined;
      case CalendarViewMode.day:
        return Icons.calendar_view_day_outlined;
    }
  }

  CalendarFormat? get calendarFormat {
    switch (this) {
      case CalendarViewMode.month:
        return CalendarFormat.month;
      case CalendarViewMode.twoWeeks:
        return CalendarFormat.twoWeeks;
      case CalendarViewMode.week:
        return CalendarFormat.week;
      case CalendarViewMode.day:
        return null;
    }
  }
}
