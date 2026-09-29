import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/config/user_config.dart';
import 'package:ink/features/notes/domain/calendar_view_mode.dart';
import 'package:ink/features/notes/domain/constants.dart';
import 'package:ink/features/notes/presentation/notifiers/notebooks_notifier.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ui_state.g.dart';

@riverpod
class SelectedNotebookId extends _$SelectedNotebookId {
  /// All notes is the landing view (D-10). The app opens on a flat,
  /// reverse-chronological list of everything, because it is note-first: the
  /// note is the thing, and due dates are a lens over it rather than the
  /// primary axis. Today stays reachable as a task-forward lens.
  @override
  String build() {
    // Seeded once, deliberately not watching the notebook list. Watching it
    // re-runs this whenever the list resolves, which silently overwrote the
    // selection the user had just made.
    return ref.read(userPreferencesProvider).selectedNotebookId ??
        allNotebooksId;
  }

  // Riverpod notifiers hold state in the base class; a paired getter is
  // not meaningful here.
  // ignore: avoid_setters_without_getters
  set id(String id) {
    state = id;
    unawaited(ref.read(userPreferencesProvider).setSelectedNotebookId(id));
  }
}

@riverpod
class SelectedNotebookTitle extends _$SelectedNotebookTitle {
  @override
  String build() {
    final selectedNotebookId = ref.watch(selectedNotebookIdProvider);
    final notebooks = ref.watch(notebooksProvider).value ?? [];

    return switch (selectedNotebookId) {
      // Previously All notes was labelled "Today", because it was not a real
      // Home lens and borrowing the label was the cheapest way to avoid a
      // second string. Now that it is the default view, it needs its own.
      _ when isContentForwardLens(selectedNotebookId) => t.notes.all,
      _ when selectedNotebookId == todayNotebookId => t.notes.today,
      // A restored id can name a notebook that no longer exists, and
      // `firstWhere` used to throw on it and take the screen down with it.
      // Falling back to the default view is the honest reading: the lens is
      // gone, so show everything rather than claim an empty notebook.
      _ =>
        notebooks.where((p) => p.id == selectedNotebookId).firstOrNull?.title ??
            t.notes.all,
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

  // Same rationale as [SelectedNotebookId.id]: no meaningful paired getter.
  // ignore: avoid_setters_without_getters
  set mode(CalendarViewMode mode) => state = mode;
}

final currentDateProvider = Provider<DateTime>((ref) => DateTime.now());

@riverpod
class CalendarSelectedDate extends _$CalendarSelectedDate {
  @override
  DateTime build() => ref.watch(currentDateProvider);

  // Same rationale as [SelectedNotebookId.id]: no meaningful paired getter.
  // ignore: avoid_setters_without_getters
  set date(DateTime date) => state = date;
}

@riverpod
class CalendarFocusedDate extends _$CalendarFocusedDate {
  @override
  DateTime build() => ref.watch(currentDateProvider);

  // Same rationale as [SelectedNotebookId.id]: no meaningful paired getter.
  // ignore: avoid_setters_without_getters
  set date(DateTime date) => state = date;
}
