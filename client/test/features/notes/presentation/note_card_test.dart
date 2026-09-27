// Step 7: the card shows content, and reads it from the cache.
//
// `bodyPreview` has been written to the `notes` table since #67, but nothing in
// presentation read it, so every card rebuilt re-parsed the Quill delta. The
// card now prefers the cached value and only derives a preview for notes that
// did not come through the local store.
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ink/core/domain/result.dart';
import 'package:ink/core/domain/sync_status.dart';
import 'package:ink/core/presentation/theme/app_theme.dart';
import 'package:ink/core/presentation/theme/palettes.dart';
import 'package:ink/features/notes/domain/entities/encrypted_note.dart';
import 'package:ink/features/notes/domain/entities/note.dart';
import 'package:ink/features/notes/domain/entities/note_metadata.dart';
import 'package:ink/features/notes/domain/entities/project.dart';
import 'package:ink/features/notes/domain/failures/notes_failure.dart';
import 'package:ink/features/notes/domain/mappers/notes_mapper.dart';
import 'package:ink/features/notes/domain/notes_providers.dart';
import 'package:ink/features/notes/domain/notes_service.dart';
import 'package:ink/features/notes/domain/task_priority.dart';
import 'package:ink/features/notes/presentation/notifiers/notes_notifier.dart';
import 'package:ink/features/notes/presentation/widgets/notes/card/active_note_card.dart';
import 'package:ink/features/notes/presentation/widgets/notes/card/note_card.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

class _Svc extends Mock implements NotesService {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      Note(
        id: 'fallback',
        title: 'fallback',
        content: [],
        localVersion: 1,
        lastSyncedVersion: 1,
        syncStatus: SyncStatus.synced,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      ),
    );
  });

  late _Svc svc;

  setUp(() {
    svc = _Svc();
    when(
      svc.getAllProjects,
    ).thenAnswer((_) async => const Success<List<Project>, NotesFailure>([]));
  });

  group('the preview is carried, not re-derived', () {
    test('toNote passes the cached preview through', () {
      final encrypted = EncryptedNote(
        id: 'n1',
        encryptedTitle: Uint8List(0),
        encryptedContent: Uint8List(0),
        localVersion: 1,
        lastSyncedVersion: 1,
        syncStatus: SyncStatus.synced,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
        metadata: const NoteMetadata(bodyPreview: 'cached preview text'),
      );

      final note = encrypted.toNote(
        title: 't',
        content: [
          {'insert': 'actual body\n'},
        ],
        isCompleted: false,
        priority: TaskPriority.none,
      );

      // The cached value wins, which is the whole point: the list no longer
      // parses the delta to render a line of text.
      expect(note.preview, 'cached preview text');
    });

    test('a note without cached metadata has an empty preview', () {
      final note = Note(
        id: 'n1',
        title: 't',
        content: [
          {'insert': 'body\n'},
        ],
        localVersion: 1,
        lastSyncedVersion: 1,
        syncStatus: SyncStatus.synced,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );

      expect(note.preview, isEmpty);
    });
  });

  group('the card', () {
    Future<void> pump(WidgetTester tester, Note note) async {
      when(
        svc.getAllNotes,
      ).thenAnswer((_) async => Success<List<Note>, NotesFailure>([note]));
      final c = ProviderContainer(
        overrides: [notesServiceProvider.overrideWithValue(svc)],
      );
      addTearDown(c.dispose);
      final sub = c.listen(notesProvider, (_, _) {});
      addTearDown(sub.close);
      await c.read(notesProvider.future);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: c,
          child: TranslationProvider(
            child: MaterialApp(
              theme: AppTheme.light(InkPalette.forest),
              home: Scaffold(
                body: ActiveNoteCard(note: note, onTap: () {}),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    Note sample({String preview = '', DateTime? dueDate, TaskPriority? p}) =>
        Note(
          id: 'n1',
          title: 'The title',
          content: [
            {'insert': 'derived from content\n'},
          ],
          preview: preview,
          localVersion: 1,
          lastSyncedVersion: 1,
          syncStatus: SyncStatus.synced,
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
          dueDate: dueDate,
          priority: p ?? TaskPriority.none,
        );

    testWidgets('prefers the cached preview', (tester) async {
      await pump(tester, sample(preview: 'from the cache'));

      expect(find.text('from the cache'), findsOneWidget);
      expect(find.text('derived from content'), findsNothing);
    });

    testWidgets('falls back to the content when no cache is present', (
      tester,
    ) async {
      // Notes built in memory, or arriving before metadata, have no cached
      // value; they must still render something.
      await pump(tester, sample());

      expect(find.text('derived from content'), findsOneWidget);
    });

    testWidgets('the meta row carries the due date', (tester) async {
      await pump(tester, sample(dueDate: DateTime(2026, 3, 9)));

      expect(find.byType(NoteMetaRow), findsOneWidget);
      expect(find.text('9 ${t.calendar.months[2]}'), findsOneWidget);
    });

    testWidgets('no meta row when there is nothing to say', (tester) async {
      await pump(tester, sample());

      expect(find.byType(NoteMetaRow), findsNothing);
    });

    testWidgets('priority is hidden when the lens says so', (tester) async {
      await pump(
        tester,
        sample(dueDate: DateTime(2026, 3, 9), p: TaskPriority.high),
      );

      // The All notes lens turns priority off; the flag used to lead the title.
      expect(find.byIcon(Icons.flag), findsNothing);
      expect(find.byIcon(Icons.flag_outlined), findsOneWidget);
    });
  });
}
