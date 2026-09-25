import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:ink/core/domain/result.dart';
import 'package:ink/core/domain/sync_status.dart';
import 'package:ink/core/infrastructure/crypto/crypto.dart';
import 'package:ink/core/services/session/crypto_session.dart';
import 'package:ink/core/services/sync/sync_orchestrator.dart';
import 'package:ink/features/notes/data/secure_notes_service.dart';
import 'package:ink/features/notes/domain/entities/encrypted_note.dart';
import 'package:ink/features/notes/domain/entities/encrypted_project.dart';
import 'package:ink/features/notes/domain/entities/note.dart';
import 'package:ink/features/notes/domain/entities/project.dart';
import 'package:ink/features/notes/domain/failures/notes_failure.dart';
import 'package:ink/features/notes/domain/models/note_creation_payload.dart';
import 'package:ink/features/notes/domain/models/project_creation_payload.dart';
import 'package:ink/features/notes/domain/notes_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockEncryptionService extends Mock implements EncryptionService {}

class _MockCryptoSession extends Mock implements CryptoSession {}

class _MockNotesRepository extends Mock implements NotesRepository {}

class _MockSyncOrchestrator extends Mock implements SyncOrchestrator {}

void main() {
  setUpAll(() {
    registerFallbackValue(Uint8List(0));
    registerFallbackValue(
      EncryptedNote(
        id: 'fallback-note',
        encryptedTitle: Uint8List(0),
        encryptedContent: Uint8List(0),
        localVersion: 1,
        lastSyncedVersion: 0,
        syncStatus: SyncStatus.modified,
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      ),
    );
    registerFallbackValue(
      EncryptedProject(
        id: 'fallback-project',
        encryptedContent: Uint8List(0),
        localVersion: 1,
        lastSyncedVersion: 0,
        syncStatus: SyncStatus.modified,
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      ),
    );
  });

  late _MockEncryptionService encryption;
  late _MockCryptoSession cryptoSession;
  late _MockNotesRepository repository;
  late _MockSyncOrchestrator sync;
  late SecureNotesService service;
  late List<String> calls;

  final key = Uint8List.fromList(List.filled(32, 7));
  final now = DateTime.utc(2026);
  final note = Note(
    id: 'note-1',
    title: 'Note',
    content: const [],
    localVersion: 1,
    lastSyncedVersion: 0,
    syncStatus: SyncStatus.modified,
    createdAt: now,
    updatedAt: now,
  );
  final project = Project(
    id: 'project-1',
    title: 'Project',
    emoji: '📁',
    colorValue: 0xFF000000,
    localVersion: 1,
    lastSyncedVersion: 0,
    syncStatus: SyncStatus.modified,
    createdAt: now,
    updatedAt: now,
  );

  setUp(() {
    encryption = _MockEncryptionService();
    cryptoSession = _MockCryptoSession();
    repository = _MockNotesRepository();
    sync = _MockSyncOrchestrator();
    calls = <String>[];

    when(() => cryptoSession.masterKey).thenReturn(key);
    when(
      () => encryption.encrypt(any(), any()),
    ).thenAnswer((_) async => Uint8List.fromList([1]));
    when(() => encryption.decrypt(any(), any())).thenAnswer(
      (_) async => Uint8List.fromList(
        utf8.encode(jsonEncode({'quillData': <dynamic>[]})),
      ),
    );
    when(() => sync.performSync()).thenAnswer((_) async {
      calls.add('sync');
    });

    service = SecureNotesService(
      encryption: encryption,
      cryptoSession: cryptoSession,
      repository: repository,
      sync: sync,
    );
  });

  test('createNote schedules sync after persistence succeeds', () async {
    final encryptedNote = EncryptedNote(
      id: 'note-1',
      encryptedTitle: Uint8List(0),
      encryptedContent: Uint8List(0),
      localVersion: 1,
      lastSyncedVersion: 0,
      syncStatus: SyncStatus.modified,
      createdAt: now,
      updatedAt: now,
    );
    when(() => repository.createNote(any(), any(), any())).thenAnswer((
      _,
    ) async {
      calls.add('persist');
      return Success(encryptedNote);
    });

    await service.createNote(
      const NoteCreationPayload(title: 'Note', content: []),
    );

    expect(calls, ['persist', 'sync']);
  });

  test('createProject schedules sync after persistence succeeds', () async {
    final encryptedProject = EncryptedProject(
      id: 'project-1',
      encryptedContent: Uint8List(0),
      localVersion: 1,
      lastSyncedVersion: 0,
      syncStatus: SyncStatus.modified,
      createdAt: now,
      updatedAt: now,
    );
    when(() => encryption.decrypt(any(), any())).thenAnswer(
      (_) async => Uint8List.fromList(
        utf8.encode(
          jsonEncode({
            'title': 'Project',
            'emoji': '📁',
            'colorValue': '#000000',
          }),
        ),
      ),
    );
    when(() => repository.createProject(any())).thenAnswer((_) async {
      calls.add('persist');
      return Success(encryptedProject);
    });

    await service.createProject(
      const ProjectCreationPayload(
        title: 'Project',
        emoji: '📁',
        colorValue: 0xFF000000,
      ),
    );

    expect(calls, ['persist', 'sync']);
  });

  test('saveNote schedules sync only after persistence succeeds', () async {
    when(() => repository.saveNote(any())).thenAnswer((_) async {
      calls.add('persist');
      return const Success(null);
    });

    await service.saveNote(note);

    expect(calls, ['persist', 'sync']);
  });

  test('deleteNote schedules sync only after persistence succeeds', () async {
    when(() => repository.deleteNote('note-1')).thenAnswer((_) async {
      calls.add('persist');
      return const Success(null);
    });

    await service.deleteNote(note);

    expect(calls, ['persist', 'sync']);
  });

  test('saveProject schedules sync only after persistence succeeds', () async {
    when(() => repository.saveProject(any())).thenAnswer((_) async {
      calls.add('persist');
      return const Success(null);
    });

    await service.saveProject(project);

    expect(calls, ['persist', 'sync']);
  });

  test(
    'deleteProject schedules sync only after persistence succeeds',
    () async {
      when(() => repository.deleteProject('project-1')).thenAnswer((_) async {
        calls.add('persist');
        return const Success(null);
      });

      await service.deleteProject(project);

      expect(calls, ['persist', 'sync']);
    },
  );

  test('failed note persistence does not schedule sync', () async {
    when(() => repository.saveNote(any())).thenAnswer((_) async {
      calls.add('persist');
      return const Failure(IdNotFound());
    });

    await service.saveNote(note);

    expect(calls, ['persist']);
  });
}
