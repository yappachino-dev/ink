import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:ink/core/domain/core_failure.dart';
import 'package:ink/core/domain/result.dart';
import 'package:ink/core/domain/sync_status.dart';
import 'package:ink/core/infrastructure/crypto/crypto.dart';
import 'package:ink/core/services/session/crypto_session.dart';
import 'package:ink/core/services/sync/sync_orchestrator.dart';
import 'package:ink/features/notes/data/secure_notes_service.dart';
import 'package:ink/features/notes/domain/entities/encrypted_note.dart';
import 'package:ink/features/notes/domain/entities/encrypted_project.dart';
import 'package:ink/features/notes/domain/entities/note.dart';
import 'package:ink/features/notes/domain/entities/note_metadata.dart';
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
    registerFallbackValue(<String, NoteMetadata>{});
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
    when(() => cryptoSession.hasKey).thenReturn(true);
    // Default: nothing is stale, so the backfill is a no-op unless a test says
    // otherwise.
    when(() => repository.findStaleMetadataNoteIds(any()))
        .thenAnswer((_) async => const Success([]));
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

  group('derived-metadata backfill', () {
    // The half of the locked-vault story that makes it safe: a note stored
    // while the vault was closed is tagged stale, and this is what repairs it
    // once the user unlocks.
    Future<void> givenStoredNote(EncryptedNote stored) async {
      when(() => repository.getAllNotes())
          .thenAnswer((_) async => Success([stored]));
    }

    EncryptedNote deferredNote() => EncryptedNote(
          id: 'note-1',
          // Distinct ciphertexts so the decrypt stub can tell the title from
          // the body; both go through the same two-argument method.
          encryptedTitle: Uint8List.fromList([9]),
          encryptedContent: Uint8List.fromList([8]),
          localVersion: 1,
          lastSyncedVersion: 1,
          syncStatus: SyncStatus.synced,
          createdAt: now,
          updatedAt: now,
          metadata: deferredNoteMetadata,
        );

    test('repairs a note that was stored while the vault was locked', () async {
      await givenStoredNote(deferredNote());
      when(() => repository.findStaleMetadataNoteIds(any()))
          .thenAnswer((_) async => const Success(['note-1']));
      when(() => encryption.decrypt(any(), any())).thenAnswer((
        invocation,
      ) async {
        final data = invocation.positionalArguments.first as Uint8List;
        if (data.first == 9) {
          return Uint8List.fromList(utf8.encode('Recovered title'));
        }
        return Uint8List.fromList(
          utf8.encode(
            jsonEncode({
              'quillData': [
                {'insert': 'Recovered body\n'},
              ],
              'dueDate': '2026-09-09T00:00:00.000',
            }),
          ),
        );
      });
      final written = <String, NoteMetadata>{};
      when(() => repository.writeNoteMetadata(any())).thenAnswer((
        invocation,
      ) async {
        final passed = invocation.positionalArguments.first;
        written.addAll(passed as Map<String, NoteMetadata>);
        return const Success(null);
      });

      await service.getAllNotes();

      expect(written, hasLength(1));
      expect(written['note-1']!.titlePreview, 'Recovered title');
      expect(written['note-1']!.bodyPreview, 'Recovered body');
      expect(written['note-1']!.dueDateDay, DateTime(2026, 9, 9));
      expect(written['note-1']!.isCurrent, isTrue);
    });

    test('writes nothing when no row is stale', () async {
      await givenStoredNote(deferredNote());
      var writes = 0;
      when(() => repository.writeNoteMetadata(any())).thenAnswer((_) async {
        writes++;
        return const Success(null);
      });

      await service.getAllNotes();

      expect(writes, 0);
    });

    test('a failed lookup does not fail the read', () async {
      // The notes are still readable without a cache; they just filter poorly
      // until a later attempt. A read must not break over that.
      await givenStoredNote(deferredNote());
      when(() => repository.findStaleMetadataNoteIds(any()))
          .thenAnswer(
            (_) async =>
                const Failure(NotesCoreFailure(UnexpectedFailure('x'))),
          );

      final result = await service.getAllNotes();

      expect(result, isA<Success<List<Note>, NotesFailure>>());
    });

    test('a note that cannot be decrypted is still marked current', () async {
      // Otherwise every subsequent read would retry the same impossible repair.
      await givenStoredNote(deferredNote());
      when(() => repository.findStaleMetadataNoteIds(any()))
          .thenAnswer((_) async => const Success(['note-1']));
      // CryptoDecryptionException is what the real cipher layer throws when the
      // key does not authenticate the payload.
      when(() => encryption.decrypt(any(), any()))
          .thenThrow(CryptoDecryptionException());
      final written = <String, NoteMetadata>{};
      when(() => repository.writeNoteMetadata(any())).thenAnswer((
        invocation,
      ) async {
        final passed = invocation.positionalArguments.first;
        written.addAll(passed as Map<String, NoteMetadata>);
        return const Success(null);
      });

      await service.getAllNotes();

      expect(written['note-1']!.isCurrent, isTrue);
    });
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
