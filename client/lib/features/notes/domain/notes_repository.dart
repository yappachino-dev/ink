import 'dart:typed_data';

import 'package:ink/core/domain/result.dart';
import 'package:ink/features/notes/domain/entities/encrypted_note.dart';
import 'package:ink/features/notes/domain/entities/encrypted_project.dart';
import 'package:ink/features/notes/domain/failures/notes_failure.dart';

abstract class NotesRepository {
  Future<Result<EncryptedNote, NotesFailure>> createNote(
    Uint8List encryptedTitle,
    Uint8List encryptedContent,
    String? projectId,
  );
  Future<Result<void, NotesFailure>> saveNote(EncryptedNote note);
  Future<Result<EncryptedNote?, NotesFailure>> getNote(String id);
  Future<Result<List<EncryptedNote>, NotesFailure>> getAllNotes();
  Future<Result<void, NotesFailure>> deleteNote(String id);

  Future<Result<EncryptedProject, NotesFailure>> createProject(
    Uint8List encryptedContent,
  );
  Future<Result<void, NotesFailure>> saveProject(EncryptedProject note);
  Future<Result<EncryptedProject?, NotesFailure>> getProject(String id);
  Future<Result<List<EncryptedProject>, NotesFailure>> getAllProjects();
  Future<Result<void, NotesFailure>> deleteProject(String id);
}
