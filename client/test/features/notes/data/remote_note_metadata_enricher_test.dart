// Step 3a: the sync write path.
//
// Remote applies carry ciphertext only, so this path has no plaintext moment
// like `Note.toEncrypted` does. If it forgets to fill the derived cache, synced
// notes still render and still sync — they just never match a filter, and
// nothing looks broken. That is the failure mode these tests exist to prevent.
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:ink/core/domain/result.dart';
import 'package:ink/core/domain/sync_status.dart';
import 'package:ink/core/services/session/crypto_session.dart';
import 'package:ink/features/notes/data/note_decryptor.dart';
import 'package:ink/features/notes/data/notes_sync_engine.dart';
import 'package:ink/features/notes/data/remote_note_metadata_enricher.dart';
import 'package:ink/features/notes/domain/entities/encrypted_note.dart';
import 'package:ink/features/notes/domain/entities/note.dart';
import 'package:ink/features/notes/domain/entities/note_metadata.dart';
import 'package:ink/features/notes/domain/failures/notes_failure.dart';
import 'package:mocktail/mocktail.dart';

class _Engine extends Mock implements NotesSyncEngine {}

class _Session extends Mock implements CryptoSession {}

class _Decryptor extends Mock implements NoteDecryptor {}

final _key = Uint8List.fromList(List.generate(32, (i) => i));

EncryptedNote _remote({String id = 'n1', String? notebookId}) => EncryptedNote(
  id: id,
  encryptedTitle: Uint8List.fromList([1, 2]),
  encryptedContent: Uint8List.fromList([3, 4]),
  localVersion: 5,
  lastSyncedVersion: 5,
  syncStatus: SyncStatus.synced,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
  notebookId: notebookId,
);

Note _decrypted({
  String title = 'Remote note',
  List<dynamic> content = const [
    {'insert': 'Remote body\n'},
  ],
  DateTime? dueDate,
}) => Note(
  id: 'n1',
  title: title,
  content: content,
  localVersion: 5,
  lastSyncedVersion: 5,
  syncStatus: SyncStatus.synced,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
  dueDate: dueDate,
);

void main() {
  setUpAll(() {
    registerFallbackValue(_remote(id: 'fallback'));
    registerFallbackValue(_key);
  });

  late _Engine inner;
  late _Session session;
  late _Decryptor decryptor;

  setUp(() {
    inner = _Engine();
    session = _Session();
    decryptor = _Decryptor();

    when(() => session.hasKey).thenReturn(true);
    when(() => session.masterKey).thenReturn(_key);
    when(
      () => inner.applyRemoteNotes(any()),
    ).thenAnswer((_) async => const Success(null));
  });

  RemoteNoteMetadataEnricher build() => RemoteNoteMetadataEnricher(
    inner: inner,
    cryptoSession: session,
    decryptor: decryptor,
  );

  test('fills the derived cache for an incoming note', () async {
    when(() => decryptor.decrypt(any(), any())).thenAnswer(
      (_) async => _decrypted(
        title: 'Synced title',
        content: [
          {'insert': 'Synced body\n'},
        ],
        dueDate: DateTime(2026, 4, 2, 18),
      ),
    );

    final result = await build().applyRemoteNotes([_remote()]);

    expect(result, isA<Success<void, NotesFailure>>());
    final written =
        verify(() => inner.applyRemoteNotes(captureAny())).captured.single
            as List<EncryptedNote>;
    final metadata = written.single.metadata;
    expect(metadata.titlePreview, 'Synced title');
    expect(metadata.bodyPreview, 'Synced body');
    expect(metadata.dueDateDay, DateTime(2026, 4, 2));
    expect(metadata.isCurrent, isTrue);
  });

  test('leaves ciphertext and sync bookkeeping untouched', () async {
    when(
      () => decryptor.decrypt(any(), any()),
    ).thenAnswer((_) async => _decrypted());

    final source = _remote(notebookId: 'notebook_1');
    await build().applyRemoteNotes([source]);

    final written =
        verify(() => inner.applyRemoteNotes(captureAny())).captured.single
            as List<EncryptedNote>;
    expect(written.single.encryptedTitle, source.encryptedTitle);
    expect(written.single.encryptedContent, source.encryptedContent);
    expect(written.single.localVersion, source.localVersion);
    expect(written.single.lastSyncedVersion, source.lastSyncedVersion);
    expect(written.single.syncStatus, source.syncStatus);
    expect(written.single.notebookId, source.notebookId);
  });

  test(
    'a note that cannot be decrypted still lands, with empty metadata',
    () async {
      // Dropping it would make the note vanish from the user's view entirely.
      // Degraded metadata is a display regression; disappearance is data loss.
      when(
        () => decryptor.decrypt(any(), any()),
      ).thenThrow(StateError('ciphertext does not match key'));

      final result = await build().applyRemoteNotes([_remote()]);

      expect(result, isA<Success<void, NotesFailure>>());
      final written =
          verify(() => inner.applyRemoteNotes(captureAny())).captured.single
              as List<EncryptedNote>;
      expect(written.single.metadata, const NoteMetadata());
      // Marked current, or every later read would retry the same failure.
      expect(written.single.metadata.isCurrent, isTrue);
    },
  );

  test('one unreadable note does not stop the rest of the batch', () async {
    when(() => decryptor.decrypt(any(), any())).thenAnswer((invocation) async {
      final note = invocation.positionalArguments.first as EncryptedNote;
      if (note.id == 'bad') throw StateError('unreadable');
      return _decrypted(title: 'good ${note.id}');
    });

    final result = await build().applyRemoteNotes([
      _remote(id: 'good1'),
      _remote(id: 'bad'),
      _remote(id: 'good2'),
    ]);

    expect(result, isA<Success<void, NotesFailure>>());
    final written =
        verify(() => inner.applyRemoteNotes(captureAny())).captured.single
            as List<EncryptedNote>;
    expect(written[0].metadata.titlePreview, 'good good1');
    expect(written[1].metadata.titlePreview, '');
    expect(written[2].metadata.titlePreview, 'good good2');
  });

  test(
    'an empty batch is passed straight through without reading the key',
    () async {
      await build().applyRemoteNotes([]);

      verify(() => inner.applyRemoteNotes([])).called(1);
      verifyNever(() => session.masterKey);
    },
  );

  test('passes read and acknowledgement calls through untouched', () async {
    when(
      () => inner.getPendingNotes(),
    ).thenAnswer((_) async => const Success([]));
    when(
      () => inner.acknowledgePushedNotes(any()),
    ).thenAnswer((_) async => const Success(null));

    final enricher = build();

    await enricher.getPendingNotes();
    await enricher.acknowledgePushedNotes([]);

    verify(() => inner.getPendingNotes()).called(1);
    verify(() => inner.acknowledgePushedNotes([])).called(1);
  });

  group('a locked vault', () {
    // Storing valid ciphertext does not require the key. Only deriving the
    // cache does, and that can wait for unlock. Throwing here would stall the
    // whole sync — notebooks and the cursor included — for as long as the vault
    // stayed locked.
    setUp(() {
      when(() => session.hasKey).thenReturn(false);
    });

    test('still stores the notes, tagged for repair after unlock', () async {
      final result = await build().applyRemoteNotes([_remote(id: 'a')]);

      expect(result, isA<Success<void, NotesFailure>>());
      final written =
          verify(() => inner.applyRemoteNotes(captureAny())).captured.single
              as List<EncryptedNote>;
      expect(written.single.id, 'a');
      expect(written.single.metadata, deferredNoteMetadata);
    });

    test('a deferred note is stale so the backfill will find it', () async {
      // The trap: `const NoteMetadata()` carries the *current* version, so
      // writing that here would make the backfill skip the note forever and
      // leave a permanently blank preview.
      await build().applyRemoteNotes([_remote()]);

      final written =
          verify(() => inner.applyRemoteNotes(captureAny())).captured.single
              as List<EncryptedNote>;
      expect(written.single.metadata.isCurrent, isFalse);
      expect(written.single.metadata.version, 0);
    });

    test('ciphertext is preserved intact', () async {
      final source = _remote(id: 'a');
      await build().applyRemoteNotes([source]);

      final written =
          verify(() => inner.applyRemoteNotes(captureAny())).captured.single
              as List<EncryptedNote>;
      expect(written.single.encryptedContent, source.encryptedContent);
      expect(written.single.encryptedTitle, source.encryptedTitle);
      expect(written.single.lastSyncedVersion, source.lastSyncedVersion);
    });

    test('never reads or touches the key', () async {
      await build().applyRemoteNotes([_remote()]);

      verifyNever(() => session.masterKey);
      verifyNever(() => decryptor.decrypt(any(), any()));
    });

    test('a whole batch defers, not just the first note', () async {
      await build().applyRemoteNotes([_remote(id: 'a'), _remote(id: 'b')]);

      final written =
          verify(() => inner.applyRemoteNotes(captureAny())).captured.single
              as List<EncryptedNote>;
      expect(written.every((n) => n.metadata == deferredNoteMetadata), isTrue);
    });
  });

  test(
    'an unlocked-but-undecryptable note is marked current, not deferred',
    () async {
      // Different failure from a locked vault: here retrying on every read
      // could never succeed, so the row must not be queued for repair forever.
      when(
        () => decryptor.decrypt(any(), any()),
      ).thenThrow(StateError('unreadable'));

      await build().applyRemoteNotes([_remote()]);

      final written =
          verify(() => inner.applyRemoteNotes(captureAny())).captured.single
              as List<EncryptedNote>;
      expect(written.single.metadata.isCurrent, isTrue);
      expect(written.single.metadata, isNot(deferredNoteMetadata));
    },
  );

  test('reads the key once for the whole batch', () async {
    when(
      () => decryptor.decrypt(any(), any()),
    ).thenAnswer((_) async => _decrypted());

    await build().applyRemoteNotes([
      _remote(id: 'a'),
      _remote(id: 'b'),
      _remote(id: 'c'),
    ]);

    verify(() => session.masterKey).called(1);
    // All three still reached the write, so the single key read covered them.
    final written =
        verify(() => inner.applyRemoteNotes(captureAny())).captured.single
            as List<EncryptedNote>;
    expect(written.map((n) => n.id).toList(), ['a', 'b', 'c']);
  });

  group('checklist detection survives the sync path', () {
    test('an unchecked item in a synced note is detected', () async {
      when(() => decryptor.decrypt(any(), any())).thenAnswer(
        (_) async => _decrypted(
          content: [
            {'insert': 'Milk\n'},
            {
              'insert': '\n',
              'attributes': {'list': 'unchecked'},
            },
          ],
        ),
      );

      await build().applyRemoteNotes([_remote()]);

      final written =
          verify(() => inner.applyRemoteNotes(captureAny())).captured.single
              as List<EncryptedNote>;
      expect(written.single.metadata.hasUncompletedTasks, isTrue);
    });
  });
}
