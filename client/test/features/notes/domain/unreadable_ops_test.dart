// The editor drops operations it cannot load, and saving writes the filtered
// result back. Without these tests the destructive path is silent, which is the
// defect: the note still decrypts, so nothing downstream reports a problem.
import 'package:flutter_test/flutter_test.dart';
import 'package:ink/features/notes/domain/quill_delta.dart';

void main() {
  group('unreadableNoteOpCount', () {
    test('counts nothing in a clean delta', () {
      expect(
        unreadableNoteOpCount([
          {'insert': 'Hello\n'},
          {
            'insert': 'bold',
            'attributes': {'bold': true},
          },
          {'insert': '\n'},
        ]),
        0,
      );
    });

    test('counts an embed, because Quill can load one', () {
      expect(
        unreadableNoteOpCount([
          {'insert': 'Hi\n'},
          {
            'insert': {'image': 'https://example.test/a.png'},
          },
        ]),
        0,
      );
    });

    test('counts operations with an insert of an unusable type', () {
      // 42 is neither text nor an embed, so no editor can render it.
      expect(
        unreadableNoteOpCount([
          {'insert': 'Hi\n'},
          {'insert': 42},
        ]),
        1,
      );
    });

    test('counts non-map entries', () {
      expect(
        unreadableNoteOpCount([
          'a string',
          7,
          null,
          {'insert': 'Hi\n'},
        ]),
        3,
      );
    });

    test('agrees with the filter it describes', () {
      // The whole point of this function is to report what usableNoteOps
      // silently drops. If the two ever disagree, the warning is a lie.
      for (final content in <List<dynamic>>[
        [],
        [
          {'insert': 'fine\n'},
        ],
        [
          {'insert': 'fine\n'},
          {'insert': 42},
          'junk',
        ],
        [
          {'nope': true},
          {'insert': 'fine\n'},
        ],
      ]) {
        final kept = usableNoteOps(content).length;
        final total = content.length;
        expect(
          total - kept,
          unreadableNoteOpCount(content),
          reason: 'for $content',
        );
      }
    });

    test('handles absent content', () {
      expect(unreadableNoteOpCount(null), 0);
    });
  });
}
