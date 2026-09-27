import 'package:ink/features/notes/domain/entities/note.dart';

/// What the notes surface is currently showing.
///
/// Offline is deliberately absent. It composes with every state below rather
/// than replacing one: a local-first app must keep showing notes while the
/// device is offline, because those notes are already on disk and decrypted.
/// Offline is surfaced separately as a banner.
sealed class NotesViewState {
  const NotesViewState();

  /// Identity for an `AnimatedSwitcher`.
  ///
  /// The type, never the instance. A rebuild that only changes the notes
  /// produces a fresh `NotesViewContent`, so an identity key would make the
  /// switcher tear the list down and rebuild it on every edit and every sync,
  /// resetting scroll to the top. Transitions between *different* states still
  /// animate; staying in one updates in place.
  Object get switcherKey => runtimeType;
}

class NotesViewLoading extends NotesViewState {
  const NotesViewLoading();
}

/// The vault holds no notes at all.
class NotesViewEmpty extends NotesViewState {
  const NotesViewEmpty();
}

/// The vault holds notes, but the selected lens matches none of them.
///
/// "You have nothing" and "you filtered your way to nothing" are different
/// situations and need different words: the first invites writing, the second
/// invites changing the filter.
class NotesViewEmptyByFilter extends NotesViewState {
  const NotesViewEmptyByFilter();
}

class NotesViewError extends NotesViewState {
  const NotesViewError(this.error);

  final Object error;
}

class NotesViewContent extends NotesViewState {
  const NotesViewContent(this.notes);

  final List<Note> notes;
}
