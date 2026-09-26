// F-24: an empty or malformed persisted delta must never crash a list.
//
// The server is zero-knowledge, so it never validates note payloads. A delta
// arrives from another client or from an older build exactly as written, which
// makes parsing it an untrusted-input boundary. Quill's `loadDocument` throws
// `ArgumentError('Document Delta cannot be empty.')` on an empty delta and
// asserts that the final insert ends with `\n`.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ink/core/domain/sync_status.dart';
import 'package:ink/core/presentation/theme/app_theme.dart';
import 'package:ink/core/presentation/theme/palettes.dart';
import 'package:ink/features/notes/domain/entities/note.dart';
import 'package:ink/features/notes/domain/quill_delta.dart';
import 'package:ink/features/notes/presentation/extensions/note_ui_extension.dart';
import 'package:ink/features/notes/presentation/quill_document.dart';
import 'package:ink/features/notes/presentation/widgets/notes/card/note_card.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';

Note _noteWith(List<dynamic> content, {String title = 'Title'}) => Note(
      id: 'n1',
      title: title,
      content: content,
      localVersion: 1,
      lastSyncedVersion: 1,
      syncStatus: SyncStatus.synced,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

void main() {
  group('notePreviewText', () {
    test('extracts plain text from a normal delta', () {
      expect(
        notePreviewText([
          {'insert': 'Hello world\n'},
        ]),
        'Hello world',
      );
    });

    test('joins multiple operations in order', () {
      expect(
        notePreviewText([
          {'insert': 'First\n'},
          {'insert': 'Second\n'},
        ]),
        'First\nSecond',
      );
    });

    test('returns empty text for an empty delta instead of throwing', () {
      expect(notePreviewText([]), '');
      expect(notePreviewText(null), '');
    });

    test('survives structurally broken operations', () {
      for (final broken in <List<dynamic>?>[
        ['plain string, not a delta'],
        [42],
        [null],
        [
          {'insert': 7},
        ],
        ['not-a-map'],
      ]) {
        expect(() => notePreviewText(broken), returnsNormally);
        expect(notePreviewText(broken), '');
      }
    });

    test('keeps the readable parts of a partly broken delta', () {
      expect(
        notePreviewText([
          {'insert': 'Readable\n'},
          {'retain': 3},
          {'insert': 'Also readable\n'},
        ]),
        'Readable\nAlso readable',
      );
    });

    test('caps long previews at the requested length', () {
      final long = List.generate(200, (i) => 'x').join();

      final preview = notePreviewText([
        {'insert': '$long\n'},
      ], maxLength: 50);

      expect(preview.length, lessThanOrEqualTo(50));
    });

    test('does not report a mostly-blank note as empty', () {
      // Whitespace beyond the cap must not mask the text that follows it.
      final preview = notePreviewText([
        {'insert': '${' ' * 400}\n'},
        {'insert': 'Real content\n'},
      ], maxLength: 10);

      expect(preview, isNotEmpty);
    });

    test('ignores embedded objects, which carry no text', () {
      expect(
        notePreviewText([
          {'insert': 'Caption\n'},
          {'insert': {'image': 'x.png'}},
        ]),
        'Caption',
      );
    });

    test('a very long note previews without building the whole document', () {
      // The point of reading the delta directly: a list of cards must not pay
      // for a full Quill AST per row. Correctness of the cap is what is
      // asserted here; wall-clock assertions would be flaky.
      final body = StringBuffer();
      for (var i = 0; i < 2000; i++) {
        body.writeln('paragraph $i');
      }

      final preview = notePreviewText([
        {'insert': body.toString()},
      ]);

      expect(preview, startsWith('paragraph 0'));
      expect(preview.length, lessThanOrEqualTo(300));
    });
  });

  group('hasNoteContent', () {
    test('is true for text and false for blank documents', () {
      expect(hasNoteContent([{'insert': 'x\n'}]), isTrue);
      expect(hasNoteContent([{'insert': '\n\n'}]), isFalse);
      expect(hasNoteContent([]), isFalse);
      expect(hasNoteContent(null), isFalse);
    });

    test('ignores length, unlike the capped preview', () {
      final padded = [
        {'insert': '${' ' * 500}\nreal text\n'},
      ];

      expect(hasNoteContent(padded), isTrue);
      // The preview is capped away to nothing; the content question is not.
      expect(notePreviewText(padded, maxLength: 10), isNotEmpty);
    });

    test('sees text that follows a run of broken operations', () {
      expect(
        hasNoteContent([
          'garbage',
          {'insert': '\n'},
          42,
          {'insert': 'survivor\n'},
        ]),
        isTrue,
      );
    });
  });

  group('normalizeNoteDelta', () {
    test('leaves a valid delta alone', () {
      expect(
        normalizeNoteDelta([
          {'insert': 'Hello\n'},
        ]),
        [
          {'insert': 'Hello\n'},
        ],
      );
    });

    test('substitutes an empty document only when nothing is usable', () {
      expect(normalizeNoteDelta([]), emptyNoteDelta);
      expect(normalizeNoteDelta(null), emptyNoteDelta);
      expect(normalizeNoteDelta(['garbage', 42]), emptyNoteDelta);
    });

    test('appends the trailing newline Quill requires', () {
      expect(
        normalizeNoteDelta([
          {'insert': 'no newline'},
        ]),
        [
          {'insert': 'no newline'},
          {'insert': '\n'},
        ],
      );
    });

    test('appends a newline after a trailing embed', () {
      expect(
        normalizeNoteDelta([
          {'insert': 'text\n'},
          {'insert': {'image': 'x.png'}},
        ]),
        [
          {'insert': 'text\n'},
          {'insert': {'image': 'x.png'}},
          {'insert': '\n'},
        ],
      );
    });

    test('preserves per-operation attributes', () {
      // A naive rebuild would flatten this and lose the formatting.
      expect(
        normalizeNoteDelta([
          {
            'insert': 'bold',
            'attributes': {'bold': true},
          },
        ]),
        [
          {
            'insert': 'bold',
            'attributes': {'bold': true},
          },
          {'insert': '\n'},
        ],
      );
    });

    test('discards only the unusable operations', () {
      expect(
        normalizeNoteDelta([
          {'insert': 'kept one\n'},
          {'retain': 4},
          'not-a-map',
          {'insert': 'kept two\n'},
        ]),
        [
          {'insert': 'kept one\n'},
          {'insert': 'kept two\n'},
        ],
      );
    });
  });

  group('parseQuillDocument', () {
    test('parses a valid delta', () {
      expect(
        parseQuillDocument([
          {'insert': 'Hello\n'},
        ]).toPlainText().trim(),
        'Hello',
      );
    });

    test('never throws, whatever the input', () {
      for (final broken in <List<dynamic>?>[
        null,
        [],
        ['string'],
        [42],
        [null],
        [
          {'insert': 'a\n'},
          {'delete': 1},
        ],
        [
          {'insert': 'a\n'},
          'not-a-map',
        ],
        [
          {'insert': 'no trailing newline'},
        ],
        [
          {'insert': {'image': 'x.png'}},
        ],
      ]) {
        expect(
          () => parseQuillDocument(broken),
          returnsNormally,
          reason: 'must not throw for $broken',
        );
      }
    });
  });

  group('a corrupt operation does not destroy the rest of the note', () {
    // The editor opens a note from this document and saves it back. If one bad
    // operation collapsed the whole body to empty, a single save would
    // overwrite every readable paragraph with nothing.
    test('the editor loads the surviving paragraphs', () {
      final document = parseQuillDocument([
        {'insert': 'Paragraph one is safe.\n'},
        {'retain': 99},
        'total garbage',
        {'insert': 'Paragraph two is safe.\n'},
      ]);

      final text = document.toPlainText();

      expect(text, contains('Paragraph one is safe.'));
      expect(text, contains('Paragraph two is safe.'));
    });

    test('a note whose operations are all unusable still opens', () {
      final document = parseQuillDocument([
        {'retain': 1},
        {'delete': 1},
      ]);

      expect(document.toPlainText().trim(), isEmpty);
    });
  });

  group('Note.subtitle survives malformed content (F-24)', () {
    test('empty delta yields an empty subtitle, not a crash', () {
      expect(_noteWith([]).subtitle, '');
    });

    test('whitespace-only delta yields an empty subtitle', () {
      expect(
        _noteWith([
          {'insert': '\n\n'},
        ]).subtitle,
        '',
      );
    });

    test('a fully malformed delta yields an empty subtitle', () {
      for (final broken in <List<dynamic>>[
        ['not a delta'],
        [42],
        [
          {'retain': 1},
          {'delete': 1},
        ],
      ]) {
        expect(_noteWith(broken).subtitle, '');
      }
    });

    test('a partly malformed delta still previews what is readable', () {
      expect(
        _noteWith([
          {'insert': 'a\n'},
          {'retain': 1},
        ]).subtitle,
        'a',
      );
    });

    test('a real delta still renders its text', () {
      expect(
        _noteWith([
          {'insert': 'Real content\n'},
        ]).subtitle,
        'Real content',
      );
    });
  });

  group('a list survives one malformed note (F-24 end-to-end)', () {
    // The reported symptom was a whole list going down, not a single bad row,
    // because the parse happens while building every card.
    testWidgets('renders healthy notes alongside an empty-delta note', (
      tester,
    ) async {
      final notes = [
        _noteWith([
          {'insert': 'Healthy body\n'},
        ], title: 'Good note'),
        _noteWith([], title: 'Empty body note'),
        _noteWith([
          {'insert': 'Another healthy body\n'},
        ], title: 'Second good note'),
        _noteWith([
          {'insert': 'Partly broken\n'},
          'garbage op',
        ], title: 'Partly broken note'),
      ];

      await tester.pumpWidget(
        ProviderScope(
          child: TranslationProvider(
            child: MaterialApp(
              theme: AppTheme.light(InkPalette.forest),
              home: Scaffold(
                body: ListView(
                  children: notes
                      .map(
                        (n) => NoteCard(
                          note: n,
                          showCompletion: false,
                          showPriority: false,
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      for (final title in [
        'Good note',
        'Empty body note',
        'Second good note',
        'Partly broken note',
      ]) {
        expect(find.text(title), findsOneWidget, reason: title);
      }
    });

    testWidgets('a delta missing its trailing newline does not throw', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: TranslationProvider(
            child: MaterialApp(
              theme: AppTheme.light(InkPalette.forest),
              home: Scaffold(
                body: NoteCard(
                  note: _noteWith([
                    {'insert': 'Body without a trailing newline'},
                  ], title: 'No newline'),
                  showCompletion: false,
                  showPriority: false,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('No newline'), findsOneWidget);
    });
  });
}
