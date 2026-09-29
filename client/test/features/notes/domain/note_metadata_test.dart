// Step 3a: the derived-metadata cache.
//
// These columns exist so lists can filter and preview in SQL instead of
// decrypting everything. The risk they introduce is silence: a write path that
// forgets to populate them produces a note that renders, sorts, and syncs fine
// but never matches a filter. So the tests below pin each derivation rule and
// each write path explicitly.
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:ink/core/domain/sync_status.dart';
import 'package:ink/features/notes/data/mappers/encrypted_note_remote_mapper.dart';
import 'package:ink/features/notes/domain/entities/encrypted_note.dart';
import 'package:ink/features/notes/domain/entities/note.dart';
import 'package:ink/features/notes/domain/entities/note_metadata.dart';
import 'package:ink/features/notes/domain/mappers/notes_mapper.dart';

Note _note({
  String title = 'Title',
  List<dynamic> content = const [
    {'insert': 'Body text\n'},
  ],
  DateTime? dueDate,
}) => Note(
  id: 'n1',
  title: title,
  content: content,
  localVersion: 1,
  lastSyncedVersion: 1,
  syncStatus: SyncStatus.synced,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
  dueDate: dueDate,
);

void main() {
  group('NoteMetadataDerivation.derive', () {
    test('captures the title and a preview of the body', () {
      final metadata = NoteMetadataDerivation.derive(
        title: 'Shopping',
        content: [
          {'insert': 'Milk and bread\n'},
        ],
      );

      expect(metadata.titlePreview, 'Shopping');
      expect(metadata.bodyPreview, 'Milk and bread');
    });

    test('trims the title', () {
      final metadata = NoteMetadataDerivation.derive(
        title: '  Padded  ',
        content: const [],
      );

      expect(metadata.titlePreview, 'Padded');
    });

    test('caps the body preview so the column stays bounded', () {
      final metadata = NoteMetadataDerivation.derive(
        title: 'Long',
        content: [
          {'insert': '${'x' * 5000}\n'},
        ],
      );

      expect(metadata.bodyPreview.length, lessThanOrEqualTo(300));
    });

    test('a note with no body derives an empty preview, not a crash', () {
      final metadata = NoteMetadataDerivation.derive(
        title: 'Title only',
        content: const [],
      );

      expect(metadata.bodyPreview, '');
      expect(metadata.titlePreview, 'Title only');
    });

    test('truncates the due date to a local calendar day', () {
      final metadata = NoteMetadataDerivation.derive(
        title: 'Due',
        content: const [],
        dueDate: DateTime(2026, 3, 14, 23, 59),
      );

      expect(metadata.dueDateDay, DateTime(2026, 3, 14));
    });

    test('keeps the recorded day rather than converting timezones', () {
      // Same rule as the journal calendar: a due date must not be re-dated by
      // the device timezone.
      final utcDue = DateTime.utc(2026, 3, 14, 23);

      final metadata = NoteMetadataDerivation.derive(
        title: 'Due',
        content: const [],
        dueDate: utcDue,
      );

      expect(metadata.dueDateDay!.day, 14);
    });

    test('a note with no due date has no filterable day', () {
      final metadata = NoteMetadataDerivation.derive(
        title: 'No due date',
        content: const [],
      );

      expect(metadata.dueDateDay, isNull);
    });

    test('is stamped with the current derivation version', () {
      final metadata = NoteMetadataDerivation.derive(
        title: 'T',
        content: const [],
      );

      expect(metadata.version, noteMetadataVersion);
      expect(metadata.isCurrent, isTrue);
    });

    test('survives malformed content without throwing', () {
      for (final broken in <List<dynamic>>[
        [],
        ['not a delta'],
        [42],
        [
          {'insert': 'kept\n'},
          {'retain': 1},
        ],
      ]) {
        expect(
          () => NoteMetadataDerivation.derive(title: 'T', content: broken),
          returnsNormally,
          reason: '$broken',
        );
      }
    });
  });

  group('local writes derive metadata', () {
    test('toEncrypted carries the derived cache', () {
      final encrypted =
          _note(
            title: 'Trip plan',
            content: [
              {'insert': 'Book flights\n'},
            ],
            dueDate: DateTime(2026, 5, 1, 9),
          ).toEncrypted(
            encryptedTitle: Uint8List.fromList([1]),
            encryptedContent: Uint8List.fromList([2]),
          );

      expect(encrypted.metadata.titlePreview, 'Trip plan');
      expect(encrypted.metadata.bodyPreview, 'Book flights');
      expect(encrypted.metadata.dueDateDay, DateTime(2026, 5));
      expect(encrypted.metadata.isCurrent, isTrue);
    });

    test('re-deriving after an edit reflects the new body', () {
      final before =
          _note(
            content: [
              {'insert': 'Old body\n'},
            ],
          ).toEncrypted(
            encryptedTitle: Uint8List.fromList([1]),
            encryptedContent: Uint8List.fromList([2]),
          );
      final after =
          _note(
            content: [
              {'insert': 'New body\n'},
            ],
          ).toEncrypted(
            encryptedTitle: Uint8List.fromList([1]),
            encryptedContent: Uint8List.fromList([2]),
          );

      expect(before.metadata.bodyPreview, 'Old body');
      expect(after.metadata.bodyPreview, 'New body');
    });
  });

  group('derived metadata is never synced', () {
    // The security invariant this whole feature could most easily violate: a
    // zero-knowledge server must never receive plaintext it cannot decrypt.
    test('the wire message carries no preview or day', () {
      final note = EncryptedNote(
        id: 'n1',
        encryptedTitle: Uint8List.fromList([1, 2, 3]),
        encryptedContent: Uint8List.fromList([4, 5, 6]),
        localVersion: 3,
        lastSyncedVersion: 3,
        syncStatus: SyncStatus.synced,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
        metadata: NoteMetadataDerivation.derive(
          title: 'Secret title',
          content: [
            {'insert': 'Secret body\n'},
          ],
          dueDate: DateTime(2026, 7, 4),
        ),
      );

      final proto = note.toProto();

      // Neither the preview text nor the plaintext title may appear anywhere in
      // the serialized message. Checked against the bytes as well as the debug
      // string, so a future bytes-typed field cannot smuggle them past a
      // string-only assertion.
      expect(proto.toString(), isNot(contains('Secret title')));
      expect(proto.toString(), isNot(contains('Secret body')));
      expect(proto.writeToBuffer().toString(), isNot(contains('Secret title')));
      expect(proto.writeToBuffer().toString(), isNot(contains('Secret body')));
    });
  });
}
