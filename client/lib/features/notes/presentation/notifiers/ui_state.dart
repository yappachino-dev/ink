import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/features/notes/domain/calendar_view_mode.dart';
import 'package:ink/features/notes/domain/constants.dart';
import 'package:ink/features/notes/presentation/notifiers/projects_notifier.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ui_state.g.dart';

@riverpod
class SelectedProjectId extends _$SelectedProjectId {
  @override
  String build() => todayProjectId;

  // Riverpod notifiers hold state in the base class; a paired getter is
  // not meaningful here.
  // ignore: avoid_setters_without_getters
  set id(String id) => state = id;
}

@riverpod
class SelectedProjectTitle extends _$SelectedProjectTitle {
  @override
  String build() {
    final selectedProjectId = ref.watch(selectedProjectIdProvider);
    final projects = ref.watch(projectsProvider).value ?? [];

    return switch (selectedProjectId) {
      _ when selectedProjectId == allProjectsId => t.home.today,
      _ when selectedProjectId == todayProjectId => t.home.today,
      _ => projects.firstWhere((p) => p.id == selectedProjectId).title,
    };
  }
}

@riverpod
class CompletedExpnaded extends _$CompletedExpnaded {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

@riverpod
class ShowDescription extends _$ShowDescription {
  @override
  bool build() => true;

  void toggle() => state = !state;
}

@riverpod
class CalendarViewModeState extends _$CalendarViewModeState {
  @override
  CalendarViewMode build() => CalendarViewMode.month;

  // Same rationale as [SelectedProjectId.id]: no meaningful paired getter.
  // ignore: avoid_setters_without_getters
  set mode(CalendarViewMode mode) => state = mode;
}

final currentDateProvider = Provider<DateTime>((ref) => DateTime.now());

@riverpod
class CalendarSelectedDate extends _$CalendarSelectedDate {
  @override
  DateTime build() => ref.watch(currentDateProvider);

  // Same rationale as [SelectedProjectId.id]: no meaningful paired getter.
  // ignore: avoid_setters_without_getters
  set date(DateTime date) => state = date;
}

@riverpod
class CalendarFocusedDate extends _$CalendarFocusedDate {
  @override
  DateTime build() => ref.watch(currentDateProvider);

  // Same rationale as [SelectedProjectId.id]: no meaningful paired getter.
  // ignore: avoid_setters_without_getters
  set date(DateTime date) => state = date;
}
