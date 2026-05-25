import 'package:ink/core/domain/core_failure.dart';
import 'package:ink/features/notes/domain/failures/notes_failure.dart';

extension NotesFailureToCore on NotesFailure {
  CoreFailure toCore() {
    return switch (this) {
      _ => UnexpectedFailure(
        Exception(
          'Unexpected failure when mapping from NotesFailure to CoreFailure',
        ),
      ),
    };
  }
}
