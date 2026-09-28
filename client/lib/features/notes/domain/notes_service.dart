import 'package:ink/core/domain/result.dart';
import 'package:ink/features/notes/domain/entities/note.dart';
import 'package:ink/features/notes/domain/entities/notebook.dart';
import 'package:ink/features/notes/domain/failures/notes_failure.dart';
import 'package:ink/features/notes/domain/models/note_creation_payload.dart';
import 'package:ink/features/notes/domain/models/notebook_creation_payload.dart';

abstract class NotesService {
  Future<Result<Note, NotesFailure>> createNote(NoteCreationPayload payload);
  Future<Result<void, NotesFailure>> saveNote(Note note);
  Future<Result<Note?, NotesFailure>> getNote(String id);
  Future<Result<List<Note>, NotesFailure>> getAllNotes();
  Future<Result<void, NotesFailure>> deleteNote(Note note);

  Future<Result<Notebook, NotesFailure>> createNotebook(
    NotebookCreationPayload payload,
  );
  Future<Result<void, NotesFailure>> saveNotebook(Notebook notebook);
  Future<Result<Notebook?, NotesFailure>> getNotebook(String id);
  Future<Result<List<Notebook>, NotesFailure>> getAllNotebooks();
  Future<Result<void, NotesFailure>> deleteNotebook(Notebook notebook);
}
