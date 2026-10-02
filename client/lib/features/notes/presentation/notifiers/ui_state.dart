import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/config/user_config.dart';
import 'package:ink/features/notes/domain/calendar_view_mode.dart';
import 'package:ink/features/notes/domain/notes_lens.dart';
import 'package:ink/features/notes/presentation/notifiers/notebooks_notifier.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ui_state.g.dart';

@riverpod
class NotesLensSelection extends _$NotesLensSelection {
  /// All notes is the landing view. The app opens on a flat,
  /// reverse-chronological list of everything, because it is note-first: the
  /// note is the thing, and due dates are a lens over it rather than the
  /// primary axis. Today stays reachable as a task-forward lens.
  @override
  NotesLens build() {
    // Seeded once, deliberately not watching the notebook list. Watching it
    // re-runs this whenever the list resolves, which silently overwrote the
    // selection the user had just made.
    final stored = ref.read(userPreferencesProvider).selectedNotebookId;
    if (stored == null || _allNotesKeys.contains(stored)) {
      return const NotesLens.all();
    }
    if (_todayKeys.contains(stored)) return const NotesLens.today();

    return NotesLens.notebook(stored);
  }

  /// Serializes the preference writes. Tapping two notebooks in quick
  /// succession queues two writes, and without this the slower one can land
  /// last and leave the file describing the lens the user moved away from.
  Future<void> _writes = Future<void>.value();

  /// Selects [lens] and persists it.
  ///
  /// The state is rolled back if the write fails. A selection the app cannot
  /// restore on the next launch is not a selection, and leaving it applied
  /// would mean the app silently disagreed with itself.
  Future<void> select(NotesLens lens) {
    final previous = state;
    state = lens;

    // Read before queueing, not inside the queued callback. The provider can
    // be disposed while a write is waiting its turn, and a Ref is unusable
    // after that, so the dependency is captured while it is still valid.
    final preferences = ref.read(userPreferencesProvider);

    final write = _writes.then((_) => _write(preferences, lens, previous));

    // Swallow on the chain only. The caller still gets the failure, but a
    // rejected write must not poison the queue for every tap after it.
    _writes = write.then((_) {}, onError: (_, _) {});

    return write;
  }

  Future<void> _write(
    UserConfig preferences,
    NotesLens lens,
    NotesLens previous,
  ) async {
    try {
      await preferences.setSelectedNotebookId(
        // All notes is the absence of a filter, so there is nothing to
        // persist. Storing it would leave a sentinel in the preference file,
        // which is exactly what this type exists to remove.
        lens is AllNotesLens ? null : lens.id,
      );
    } catch (_) {
      // Only undo the selection if this write is still the current one. If a
      // later tap already moved on, restoring would drag the list back to a
      // lens the user has left.
      if (ref.mounted && state == lens) state = previous;
      rethrow;
    }
  }
}

/// Persistence keys for the Today lens. Notebook lenses store their own id, and
/// All notes stores nothing, so Today is the one lens that needs a reserved
/// word.
///
/// `__today__` is what the old string sentinel persisted before [NotesLens]
/// replaced it, and it is still read so an install left on Today does not
/// reopen as a notebook that does not exist.
const _todayKeys = {'today', '__today__'};

/// The same, for the All notes lens. Today is the only lens written under a
/// reserved word now, but the old default persisted `__all__`, and an install
/// left on the default must not reopen as a phantom notebook either.
const _allNotesKeys = {'__all__'};

@riverpod
class SelectedNotebookTitle extends _$SelectedNotebookTitle {
  @override
  String build() {
    final lens = ref.watch(notesLensSelectionProvider);
    final notebooks = ref.watch(notebooksProvider).value ?? [];

    return switch (lens) {
      AllNotesLens() => t.notes.all,
      TodayLens() => t.notes.today,
      // A restored id can name a notebook that no longer exists. Falling back
      // to the default view is the honest reading: the lens is gone, so show
      // everything rather than claim an empty notebook.
      NotebookLens(:final notebookId) =>
        notebooks.where((n) => n.id == notebookId).firstOrNull?.title ??
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
