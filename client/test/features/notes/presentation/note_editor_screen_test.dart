// Step 6: writing is a destination, not a sheet.
//
// Two of these cover a real defect the golden found. A route can be
// deep-linked, so the note is not in memory when the screen builds; reading it
// once in `initState` and treating a miss as "new note" opened an empty
// editor and, on save, created a *duplicate* rather than editing.
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ink/core/domain/result.dart';
import 'package:ink/core/domain/sync_status.dart';
import 'package:ink/core/presentation/theme/app_theme.dart';
import 'package:ink/core/presentation/theme/palettes.dart';
import 'package:ink/features/notes/domain/constants.dart';
import 'package:ink/features/notes/domain/entities/note.dart';
import 'package:ink/features/notes/domain/entities/project.dart';
import 'package:ink/features/notes/domain/failures/notes_failure.dart';
import 'package:ink/features/notes/domain/models/note_creation_payload.dart';
import 'package:ink/features/notes/domain/notes_providers.dart';
import 'package:ink/features/notes/domain/notes_service.dart';
import 'package:ink/features/notes/domain/quill_delta.dart';
import 'package:ink/features/notes/domain/task_priority.dart';
import 'package:ink/features/notes/presentation/notifiers/notes_notifier.dart';
import 'package:ink/features/notes/presentation/notifiers/ui_state.dart';
import 'package:ink/features/notes/presentation/screens/note_editor_screen.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

class _Svc extends Mock implements NotesService {}

class _AllSelected extends SelectedProjectId {
  @override
  String build() => allProjectsId;
}

Note _note(String id, {String? firstLine = 'Review architecture'}) => Note(
  id: id,
  title: firstLine ?? 'Untitled',
  content: [
    {'insert': '$firstLine\nbody text here\n'},
  ],
  localVersion: 1,
  lastSyncedVersion: 1,
  syncStatus: SyncStatus.synced,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
  projectId: 'p1',
  priority: TaskPriority.medium,
);

void main() {
  setUpAll(() {
    registerFallbackValue(
      const NoteCreationPayload(title: 'fallback', content: []),
    );
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

  Future<ProviderContainer> containerOf(List<Note> notes) async {
    when(
      svc.getAllNotes,
    ).thenAnswer((_) async => Success<List<Note>, NotesFailure>(notes));
    final c = ProviderContainer(
      overrides: [
        notesServiceProvider.overrideWithValue(svc),
        selectedProjectIdProvider.overrideWith(_AllSelected.new),
      ],
    );
    addTearDown(c.dispose);
    final sub = c.listen(notesProvider, (_, _) {});
    addTearDown(sub.close);
    return c;
  }

  Future<void> pump(
    WidgetTester tester,
    ProviderContainer c,
    String? id,
  ) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: TranslationProvider(
          child: MaterialApp(
            theme: AppTheme.light(InkPalette.forest),
            localizationsDelegates: const [FlutterQuillLocalizations.delegate],
            home: NoteEditorScreen(noteId: id),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('a deep-linked note loads into the editor', (tester) async {
    final c = await containerOf([_note('n1')]);
    await pump(tester, c, 'n1');

    // The load is async: early frames see no note. What matters is that the
    // screen resolves to the editor rather than the missing-note state, and
    // that the seeded form is the note's own.
    expect(find.text(t.note.notFound), findsNothing);
    expect(find.byIcon(Icons.calendar_today_outlined), findsOneWidget);
    expect(find.byIcon(Icons.folder_outlined), findsOneWidget);
  });

  testWidgets('an unknown id says so instead of opening a blank editor', (
    tester,
  ) async {
    final c = await containerOf([_note('n1')]);
    await pump(tester, c, 'does-not-exist');

    expect(find.text(t.note.notFound), findsOneWidget);
  });

  testWidgets('a blank editor is not offered as a save target', (tester) async {
    // With no document, D-2 has no first line to use as a title, so saving is
    // a no-op rather than creating a titled empty note.
    final c = await containerOf([]);
    await pump(tester, c, null);

    expect(find.byIcon(Icons.check), findsOneWidget);
    await tester.tap(find.byIcon(Icons.check));
    await tester.pumpAndSettle();

    verifyNever(() => svc.createNote(any()));
    verifyNever(() => svc.saveNote(any()));
  });

  testWidgets('the save action is present in the app bar', (tester) async {
    // The golden cannot confirm this: the debug ribbon sits over the app bar's
    // right-hand action at the golden's aspect ratio.
    final c = await containerOf([_note('n1')]);
    await pump(tester, c, 'n1');

    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
  });

  group('the first line is the title (D-2)', () {
    test('reads the first non-empty line', () {
      expect(
        noteTitleFromContent([
          {'insert': '\n\n  Shopping list  \nmore\n'},
        ]),
        'Shopping list',
      );
    });

    test('skips leading blank lines', () {
      expect(
        noteTitleFromContent([
          {'insert': '\n\nActual title\nbody\n'},
        ]),
        'Actual title',
      );
    });

    test('is empty when there is no text', () {
      expect(
        noteTitleFromContent([
          {'insert': '\n\n'},
        ]),
        '',
      );
      expect(noteTitleFromContent([]), '');
      expect(noteTitleFromContent(null), '');
    });

    test('survives a malformed delta', () {
      expect(
        noteTitleFromContent([
          {'insert': 'Title\n'},
          'not-an-op',
          {'noInsert': 'ignored'},
          {'insert': 'body\n'},
        ]),
        'Title',
      );
    });
  });
}
