import 'package:freezed_annotation/freezed_annotation.dart';

part 'notes_lens.freezed.dart';

/// Which slice of the notes the Notes tab is showing.
///
/// This replaces two magic strings that used to travel inside the notebook id:
/// `'__all__'` standing for "no filter" and `'__today__'` standing for a lens.
/// Both were invisible to the type system, so every reader had to know the
/// sentinels, and a stale id read as a notebook that does not exist.
///
/// The three cases are genuinely different things rather than three
/// notebooks, so they are three types. A switch over [NotesLens] is
/// exhaustive, and adding a lens is a compile error at every site that has to
/// describe it rather than a silently unhandled string.
@freezed
sealed class NotesLens with _$NotesLens {
  /// Everything, unfiltered. The landing view: content-forward, ordered by last
  /// touch.
  const factory NotesLens.all() = AllNotesLens;

  /// Due today. A lens over due dates, not a notebook.
  const factory NotesLens.today() = TodayLens;

  /// One notebook's contents.
  const factory NotesLens.notebook(String notebookId) = NotebookLens;
}

/// A stable, persistable key for this lens.
///
/// Used for the stored preference and as the widget key that gives the list a
/// fresh identity on every lens change. Two lenses must never share one, or the
/// list would keep the previous lens's scroll and expanded state.
extension NotesLensId on NotesLens {
  String get id => switch (this) {
    AllNotesLens() => 'all',
    TodayLens() => 'today',
    NotebookLens(:final notebookId) => notebookId,
  };

  /// Whether the notes list renders flat and content-forward rather than
  /// task-forward.
  ///
  /// All notes answers "what do I have", so it carries no completion state, no
  /// priority, and no due date as the primary axis. Today and each notebook
  /// answer "what is left to do" and keep task-shaped rows.
  bool get isContentForward => this is AllNotesLens;

  /// Whether this is the lens for [notebookId].
  ///
  /// Freezed already gives the union value equality, so comparing against
  /// `NotesLens.notebook(id)` is correct. This exists because "is this the lens
  /// for that notebook" is asked in three places in the drawer, and reading it
  /// as a question beats reconstructing the lens just to compare it.
  bool isNotebook(String notebookId) => switch (this) {
    // The binding is renamed deliberately: `NotebookLens(:final notebookId)`
    // would shadow the parameter with the field, making the comparison a
    // tautology that answers true for every notebook lens.
    NotebookLens(notebookId: final lensId) => lensId == notebookId,
    _ => false,
  };
}
