// The notebook relationship has to survive the whole decrypt path, and nothing
// in the type system enforces that it does.
//
// `NoteDecryptor` rebuilds a domain `Note` from an `EncryptedNote` row. It does
// not name `notebookId` in its argument list at all, and that is correct only
// because `toNote` is an extension *on* `EncryptedNote` and reads the field off
// the receiver. Every argument it does pass - title, content, priority, due
// date - is an explicitly supplied parameter, so the one field that is not is
// invisible at the call site and easy to mistake for a dropped column.
//
// This was reported as a critical runtime bug. It is not one, and this test is
// what says so: it walks a note with a notebook attached all the way through
// `NoteDecryptor` and asserts the link is still there.
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:ink/core/domain/sync_status.dart';
import 'package:ink/core/infrastructure/crypto/encryption.dart';
import 'package:ink/features/notes/data/note_decryptor.dart';
import 'package:ink/features/notes/domain/entities/encrypted_note.dart';
import 'package:mocktail/mocktail.dart';

class _MockEncryption extends Mock implements EncryptionService {}

void main() {
  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  final key = Uint8List.fromList(List.filled(32, 7));

  test('the notebook link survives the decrypt path', () async {
    final encryption = _MockEncryption();
    // The title and the body decrypt to different values, so the stub has to
    // answer per call rather than returning one constant for both.
    var call = 0;
    when(() => encryption.decrypt(any(), any())).thenAnswer((_) async {
      call++;
      final body = call == 1 ? 'My note' : '{"quillData": []}';
      return Uint8List.fromList(utf8.encode(body));
    });

    const notebookId = 'nb-1';
    final encrypted = EncryptedNote(
      id: 'note-1',
      encryptedTitle: Uint8List(0),
      encryptedContent: Uint8List(0),
      localVersion: 1,
      lastSyncedVersion: 1,
      syncStatus: SyncStatus.synced,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
      notebookId: notebookId,
    );

    final note = await NoteDecryptor(encryption).decrypt(encrypted, key);

    expect(
      note.notebookId,
      notebookId,
      reason: 'the decrypt path must carry the notebook reference',
    );
  });

  test('a note with no notebook still decrypts to a null notebook', () async {
    final encryption = _MockEncryption();
    var call = 0;
    when(() => encryption.decrypt(any(), any())).thenAnswer((_) async {
      call++;
      final body = call == 1 ? 'Unfiled' : '{"quillData": []}';
      return Uint8List.fromList(utf8.encode(body));
    });

    final encrypted = EncryptedNote(
      id: 'note-2',
      encryptedTitle: Uint8List(0),
      encryptedContent: Uint8List(0),
      localVersion: 1,
      lastSyncedVersion: 1,
      syncStatus: SyncStatus.synced,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

    final note = await NoteDecryptor(encryption).decrypt(encrypted, key);
    expect(note.notebookId, isNull);
  });
}
