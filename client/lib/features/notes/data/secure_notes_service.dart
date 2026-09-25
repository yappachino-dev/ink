import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:ink/core/domain/core_failure.dart';
import 'package:ink/core/domain/result.dart';
import 'package:ink/core/infrastructure/crypto/crypto.dart';
import 'package:ink/core/infrastructure/logger.dart';
import 'package:ink/core/services/session/crypto_session.dart';
import 'package:ink/core/services/session/session_exceptions.dart';
import 'package:ink/core/services/session/session_manager.dart';
import 'package:ink/core/services/sync/sync_orchestrator.dart';
import 'package:ink/features/notes/data/models/note_payload.dart';
import 'package:ink/features/notes/data/models/project_payload.dart';
import 'package:ink/features/notes/data/unified_notes_repository.dart';
import 'package:ink/features/notes/domain/entities/encrypted_note.dart';
import 'package:ink/features/notes/domain/entities/encrypted_project.dart';
import 'package:ink/features/notes/domain/entities/note.dart';
import 'package:ink/features/notes/domain/entities/project.dart';
import 'package:ink/features/notes/domain/failures/notes_failure.dart';
import 'package:ink/features/notes/domain/mappers/notes_mapper.dart';
import 'package:ink/features/notes/domain/mappers/projects_mapper.dart';
import 'package:ink/features/notes/domain/models/note_creation_payload.dart';
import 'package:ink/features/notes/domain/models/project_creation_payload.dart';
import 'package:ink/features/notes/domain/notes_repository.dart';
import 'package:ink/features/notes/domain/notes_service.dart';
import 'package:ink/features/notes/domain/value_objects/note_time.dart';
import 'package:material_ui/material_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'secure_notes_service.g.dart';

class SecureNotesService implements NotesService {
  SecureNotesService({
    required EncryptionService encryption,
    required CryptoSession cryptoSession,
    required NotesRepository repository,
    required SyncOrchestrator sync,
  }) : _encryption = encryption,
       _cryptoSession = cryptoSession,
       _repository = repository,
       _sync = sync;

  final EncryptionService _encryption;
  final CryptoSession _cryptoSession;
  final NotesRepository _repository;
  final SyncOrchestrator _sync;

  @override
  Future<Result<Note, NotesFailure>> createNote(NoteCreationPayload payload) {
    return _guard(() async {
      final masterKey = _cryptoSession.masterKey;

      final p = NotePayload(
        quillData: payload.content,
        dueDate: payload.dueDate,
        dueTime: _toTimeOfDay(payload.dueTime),
        priority: payload.priority,
        reminderMinutesBefore: payload.reminderMinutesBefore,
      );

      final plainContent = jsonEncode(p.toJson());

      final encryptedTitle = await _encryption.encryptString(
        payload.title,
        masterKey,
      );
      final encryptedContent = await _encryption.encryptString(
        plainContent,
        masterKey,
      );

      final result = await _repository.createNote(
        encryptedTitle,
        encryptedContent,
        payload.projectId,
      );
      if (result case Failure(error: final e)) return Failure(e);
      final encryptedNote = result.unwrap;

      _scheduleSync();
      final note = await _decryptNote(encryptedNote, masterKey);

      return Success(note);
    });
  }

  @override
  Future<Result<void, NotesFailure>> saveNote(Note note) async {
    return _guard(() async {
      final masterKey = _cryptoSession.masterKey;

      final payload = NotePayload(
        quillData: note.content,
        isCompleted: note.isCompleted,
        dueDate: note.dueDate,
        dueTime: _toTimeOfDay(note.dueTime),
        priority: note.priority,
        reminderMinutesBefore: note.reminderMinutesBefore,
      );

      final plainContent = jsonEncode(payload.toJson());

      final encryptedTitle = await _encryption.encryptString(
        note.title,
        masterKey,
      );
      final encryptedContent = await _encryption.encryptString(
        plainContent,
        masterKey,
      );

      final encryptedNote = note.toEncrypted(
        encryptedTitle: encryptedTitle,
        encryptedContent: encryptedContent,
      );

      final result = await _repository.saveNote(encryptedNote);
      if (result case Failure(error: final e)) return Failure(e);

      _scheduleSync();
      return result;
    });
  }

  @override
  Future<Result<Note?, NotesFailure>> getNote(String id) async {
    return _guard(() async {
      final masterKey = _cryptoSession.masterKey;

      final encryptedNoteResult = await _repository.getNote(id);
      if (encryptedNoteResult case Failure(error: final e)) return Failure(e);

      final encryptedNote = encryptedNoteResult.unwrap;

      if (encryptedNote == null) {
        return const Failure(IdNotFound());
      }

      final note = await _decryptNote(encryptedNote, masterKey);

      return Success(note);
    });
  }

  @override
  Future<Result<List<Note>, NotesFailure>> getAllNotes() async {
    return _guard(() async {
      final masterKey = _cryptoSession.masterKey;

      final encryptedNoteResult = await _repository.getAllNotes();
      if (encryptedNoteResult case Failure(error: final e)) return Failure(e);

      final encryptedNotes = encryptedNoteResult.unwrap;

      if (encryptedNotes.isEmpty) return const Success([]);

      final notes = await Future.wait(
        encryptedNotes.map((e) => _decryptNote(e, masterKey)),
      );

      return Success(notes);
    });
  }

  @override
  Future<Result<void, NotesFailure>> deleteNote(Note note) {
    return _guard(() async {
      final result = await _repository.deleteNote(note.id);
      if (result case Failure(error: final e)) return Failure(e);

      _scheduleSync();
      return result;
    });
  }

  void _scheduleSync() {
    unawaited(_sync.performSync());
  }

  Future<Note> _decryptNote(
    EncryptedNote encryptedNote,
    Uint8List masterKey,
  ) async {
    final title = await _encryption.decryptString(
      encryptedNote.encryptedTitle,
      masterKey,
    );
    final plainContent = await _encryption.decryptString(
      encryptedNote.encryptedContent,
      masterKey,
    );

    final notePayload = NotePayload.fromJson(
      jsonDecode(plainContent) as Map<String, dynamic>,
    );

    final note = encryptedNote.toNote(
      title: title,
      content: notePayload.quillData,
      isCompleted: notePayload.isCompleted,
      priority: notePayload.priority,
      dueDate: notePayload.dueDate,
      dueTime: notePayload.dueTime == null
          ? null
          : (
              hour: notePayload.dueTime!.hour,
              minute: notePayload.dueTime!.minute,
            ),
      reminderMinutesBefore: notePayload.reminderMinutesBefore,
    );

    return note;
  }

  @override
  Future<Result<Project, NotesFailure>> createProject(
    ProjectCreationPayload payload,
  ) {
    return _guard(() async {
      final masterKey = _cryptoSession.masterKey;

      final p = ProjectPayload(
        title: payload.title,
        emoji: payload.emoji,
        colorValue: Color(payload.colorValue),
      );

      final plainContent = jsonEncode(p.toJson());

      final encryptedContent = await _encryption.encryptString(
        plainContent,
        masterKey,
      );

      final result = await _repository.createProject(encryptedContent);
      if (result case Failure(error: final e)) return Failure(e);
      final encryptedProject = result.unwrap;

      _scheduleSync();
      final project = await _decryptProject(encryptedProject, masterKey);

      return Success(project);
    });
  }

  @override
  Future<Result<void, NotesFailure>> saveProject(Project project) {
    return _guard(() async {
      final masterKey = _cryptoSession.masterKey;

      final payload = ProjectPayload(
        title: project.title,
        emoji: project.emoji,
        colorValue: Color(project.colorValue),
      );

      final plainContent = jsonEncode(payload.toJson());

      final encryptedContent = await _encryption.encryptString(
        plainContent,
        masterKey,
      );

      final encryptedProject = project.toEncrypted(
        encryptedContent: encryptedContent,
      );

      final result = await _repository.saveProject(encryptedProject);
      if (result case Failure(error: final e)) return Failure(e);

      _scheduleSync();
      return result;
    });
  }

  @override
  Future<Result<Project?, NotesFailure>> getProject(String id) {
    return _guard(() async {
      final masterKey = _cryptoSession.masterKey;

      final encryptedProjectResult = await _repository.getProject(id);
      if (encryptedProjectResult case Failure(error: final e)) {
        return Failure(e);
      }

      final encryptedProject = encryptedProjectResult.unwrap;

      if (encryptedProject == null) {
        return const Failure(IdNotFound());
      }

      final note = await _decryptProject(encryptedProject, masterKey);

      return Success(note);
    });
  }

  @override
  Future<Result<List<Project>, NotesFailure>> getAllProjects() {
    return _guard(() async {
      final masterKey = _cryptoSession.masterKey;

      final encryptedProjectsResult = await _repository.getAllProjects();
      if (encryptedProjectsResult case Failure(error: final e)) {
        return Failure(e);
      }

      final encryptedProjects = encryptedProjectsResult.unwrap;

      if (encryptedProjects.isEmpty) return const Success([]);

      final projects = await Future.wait(
        encryptedProjects.map((e) => _decryptProject(e, masterKey)),
      );

      return Success(projects);
    });
  }

  @override
  Future<Result<void, NotesFailure>> deleteProject(Project project) {
    return _guard(() async {
      final result = await _repository.deleteProject(project.id);
      if (result case Failure(error: final e)) return Failure(e);

      _scheduleSync();
      return result;
    });
  }

  Future<Project> _decryptProject(
    EncryptedProject encryptedProject,
    Uint8List masterKey,
  ) async {
    final plainContent = await _encryption.decryptString(
      encryptedProject.encryptedContent,
      masterKey,
    );

    final projectPayload = ProjectPayload.fromJson(
      jsonDecode(plainContent) as Map<String, dynamic>,
    );

    final project = encryptedProject.toProject(
      title: projectPayload.title,
      emoji: projectPayload.emoji,
      colorValue: projectPayload.colorValue.toARGB32(),
    );

    return project;
  }

  TimeOfDay? _toTimeOfDay(NoteTime? time) {
    if (time == null) return null;
    return TimeOfDay(hour: time.hour, minute: time.minute);
  }

  Future<Result<T, NotesFailure>> _guard<T>(
    Future<Result<T, NotesFailure>> Function() action,
  ) async {
    try {
      return await action();
    } on SessionLockedException catch (_) {
      return const Failure(SessionLocked());
    } on CryptoException catch (e) {
      return Failure(NotesCoreFailure(CryptoFailure(e.message)));
    } on Exception catch (e, st) {
      logger.e('SecureNotesService operation failed', error: e, stackTrace: st);
      return Failure(NotesCoreFailure(UnexpectedFailure(e)));
    }
  }
}

@riverpod
NotesService secureNotesService(Ref ref) => SecureNotesService(
  encryption: ref.watch(encryptionServiceProvider),
  cryptoSession: ref.watch(cryptoSessionProvider),
  repository: ref.watch(notesRepositoryProvider),
  sync: ref.watch(syncOrchestratorProvider.notifier),
);
