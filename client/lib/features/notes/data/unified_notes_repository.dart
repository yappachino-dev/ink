import 'dart:typed_data';

import 'package:ink/core/domain/result.dart';
import 'package:ink/core/infrastructure/data_source_runner.dart';
import 'package:ink/core/services/sync/sync_types.dart';
import 'package:ink/features/notes/data/notes_sync_engine.dart';
import 'package:ink/features/notes/data/ports/notes_local_store.dart';
import 'package:ink/features/notes/data/ports/projects_local_store.dart';
import 'package:ink/features/notes/data/projects_sync_engine.dart';
import 'package:ink/features/notes/data/sources/notes_local_store_provider.dart';
import 'package:ink/features/notes/data/sources/projects_local_store_provider.dart';
import 'package:ink/features/notes/domain/entities/encrypted_note.dart';
import 'package:ink/features/notes/domain/entities/encrypted_project.dart';
import 'package:ink/features/notes/domain/entities/note_metadata.dart';
import 'package:ink/features/notes/domain/failures/notes_failure.dart';
import 'package:ink/features/notes/domain/notes_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'unified_notes_repository.g.dart';

class UnifiedNotesRepository
    with DataSourceRunner
    implements NotesRepository, NotesSyncEngine, ProjectsSyncEngine {
  UnifiedNotesRepository({
    required NotesLocalStore localNotes,
    required ProjectsLocalStore localProjects,
  }) : _localNotes = localNotes,
       _localProjects = localProjects;

  final NotesLocalStore _localNotes;
  final ProjectsLocalStore _localProjects;

  @override
  Future<Result<EncryptedNote, NotesFailure>> createNote(
    Uint8List encryptedTitle,
    Uint8List encryptedContent,
    String? projectId,
  ) {
    return localRunner(
      call: () => _localNotes.createNote(
        encryptedTitle,
        encryptedContent,
        projectId,
      ),
      mapCore: NotesCoreFailure.new,
    );
  }

  @override
  Future<Result<void, NotesFailure>> saveNote(EncryptedNote note) {
    return localRunner(
      call: () => _localNotes.saveNote(note),
      mapCore: NotesCoreFailure.new,
    );
  }

  @override
  Future<Result<EncryptedNote?, NotesFailure>> getNote(String id) {
    return localRunner(
      call: () => _localNotes.getNote(id),
      mapCore: NotesCoreFailure.new,
    );
  }

  @override
  Future<Result<List<EncryptedNote>, NotesFailure>> getAllNotes() {
    return localRunner(
      call: _localNotes.getAllNotes,
      mapCore: NotesCoreFailure.new,
    );
  }

  @override
  Future<Result<void, NotesFailure>> deleteNote(String id) {
    return localRunner(
      call: () => _localNotes.deleteNote(id),
      mapCore: NotesCoreFailure.new,
    );
  }

  @override
  Future<Result<EncryptedProject, NotesFailure>> createProject(
    Uint8List encryptedContent,
  ) {
    return localRunner(
      call: () => _localProjects.createProject(encryptedContent),
      mapCore: NotesCoreFailure.new,
    );
  }

  @override
  Future<Result<void, NotesFailure>> saveProject(EncryptedProject project) {
    return localRunner(
      call: () => _localProjects.saveProject(project),
      mapCore: NotesCoreFailure.new,
    );
  }

  @override
  Future<Result<EncryptedProject?, NotesFailure>> getProject(String id) {
    return localRunner(
      call: () => _localProjects.getProject(id),
      mapCore: NotesCoreFailure.new,
    );
  }

  @override
  Future<Result<List<EncryptedProject>, NotesFailure>> getAllProjects() {
    return localRunner(
      call: _localProjects.getAllProjects,
      mapCore: NotesCoreFailure.new,
    );
  }

  @override
  Future<Result<void, NotesFailure>> deleteProject(String id) {
    return localRunner(
      call: () => _localProjects.deleteProject(id),
      mapCore: NotesCoreFailure.new,
    );
  }

  @override
  Future<Result<List<EncryptedNote>, NotesFailure>> getPendingNotes() {
    return localRunner(
      call: _localNotes.getPendingNotes,
      mapCore: NotesCoreFailure.new,
    );
  }

  @override
  Future<Result<void, NotesFailure>> acknowledgePushedNotes(
    List<SyncAck> acknowledgements,
  ) {
    return localRunner(
      call: () => _localNotes.acknowledgePushedNotes(acknowledgements),
      mapCore: NotesCoreFailure.new,
    );
  }

  @override
  Future<Result<List<String>, NotesFailure>> findStaleMetadataNoteIds(
    int currentVersion,
  ) {
    return localRunner(
      call: () => _localNotes.findStaleMetadataNoteIds(currentVersion),
      mapCore: NotesCoreFailure.new,
    );
  }

  @override
  Future<Result<void, NotesFailure>> writeNoteMetadata(
    Map<String, NoteMetadata> byNoteId,
  ) {
    return localRunner(
      call: () => _localNotes.writeNoteMetadata(byNoteId),
      mapCore: NotesCoreFailure.new,
    );
  }

  @override
  Future<Result<void, NotesFailure>> applyRemoteNotes(
    List<EncryptedNote> remoteData,
  ) {
    return localRunner(
      call: () => _localNotes.applyRemoteNotes(remoteData),
      mapCore: NotesCoreFailure.new,
    );
  }

  @override
  Future<Result<List<EncryptedProject>, NotesFailure>> getPendingProjects() {
    return localRunner(
      call: _localProjects.getPendingProjects,
      mapCore: NotesCoreFailure.new,
    );
  }

  @override
  Future<Result<void, NotesFailure>> acknowledgePushedProjects(
    List<SyncAck> acknowledgements,
  ) {
    return localRunner(
      call: () => _localProjects.acknowledgePushedProjects(acknowledgements),
      mapCore: NotesCoreFailure.new,
    );
  }

  @override
  Future<Result<void, NotesFailure>> applyRemoteProjects(
    List<EncryptedProject> remoteData,
  ) {
    return localRunner(
      call: () => _localProjects.applyRemoteProjects(remoteData),
      mapCore: NotesCoreFailure.new,
    );
  }
}

@riverpod
NotesRepository notesRepository(Ref ref) =>
    ref.watch(unifiedNotesRepositoryProvider);

@riverpod
UnifiedNotesRepository unifiedNotesRepository(Ref ref) =>
    UnifiedNotesRepository(
      localNotes: ref.watch(notesLocalStoreProvider),
      localProjects: ref.watch(projectsLocalStoreProvider),
    );
