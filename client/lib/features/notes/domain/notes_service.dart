import 'package:ink/core/domain/result.dart';
import 'package:ink/features/notes/domain/entities/note.dart';
import 'package:ink/features/notes/domain/entities/project.dart';
import 'package:ink/features/notes/domain/failures/notes_failure.dart';
import 'package:ink/features/notes/domain/models/note_creation_payload.dart';
import 'package:ink/features/notes/domain/models/project_creation_payload.dart';

abstract class NotesService {
  Future<Result<Note, NotesFailure>> createNote(NoteCreationPayload payload);
  Future<Result<void, NotesFailure>> saveNote(Note note);
  Future<Result<Note?, NotesFailure>> getNote(String id);
  Future<Result<List<Note>, NotesFailure>> getAllNotes();
  Future<Result<void, NotesFailure>> deleteNote(Note note);

  Future<Result<Project, NotesFailure>> createProject(
    ProjectCreationPayload payload,
  );
  Future<Result<void, NotesFailure>> saveProject(Project project);
  Future<Result<Project?, NotesFailure>> getProject(String id);
  Future<Result<List<Project>, NotesFailure>> getAllProjects();
  Future<Result<void, NotesFailure>> deleteProject(Project project);
}
