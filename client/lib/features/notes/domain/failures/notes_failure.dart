import 'package:ink/core/domain/core_failure.dart';

sealed class NotesFailure implements Exception {
  const NotesFailure();
}

class IdNotFound extends NotesFailure {
  const IdNotFound();
}

class SessionLocked extends NotesFailure {
  const SessionLocked();
}

class NotesCoreFailure extends NotesFailure {
  const NotesCoreFailure(this.core);

  final CoreFailure core;
}
