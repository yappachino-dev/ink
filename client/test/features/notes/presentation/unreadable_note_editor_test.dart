// F-25: the editor builds its document from the *filtered* delta and saves
// the filtered result, so operations the editor could not load are destroyed
// on the first save. Nothing said so. These tests pin the warning at both ends:
// visible while editing, and a gate on the save that destroys the data.
import 'dart:async';

import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ink/core/config/user_config.dart';
import 'package:ink/core/domain/result.dart';
import 'package:ink/core/domain/sync_status.dart';
import 'package:ink/core/presentation/theme/app_theme.dart';
import 'package:ink/core/presentation/theme/palettes.dart';
import 'package:ink/features/notes/domain/entities/note.dart';
import 'package:ink/features/notes/domain/entities/notebook.dart';
import 'package:ink/features/notes/domain/failures/notes_failure.dart';
import 'package:ink/features/notes/domain/notes_providers.dart';
import 'package:ink/features/notes/domain/notes_service.dart';
import 'package:ink/features/notes/presentation/notifiers/notes_notifier.dart';
import 'package:ink/features/notes/presentation/notifiers/providers/note_by_id.dart';
import 'package:ink/features/notes/presentation/notifiers/ui_state.dart';
import 'package:ink/features/notes/presentation/screens/note_editor_screen.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';

import 'package:mocktail/mocktail.dart';

import '../../../helpers/test_helpers.dart';

class _Svc extends Mock implements NotesService {}

final _day = DateTime(2026, 3, 14);

/// A note whose delta has one operation no editor can render.
///
/// `{'insert': 42}` is neither text nor an embed, so `usableNoteOps` drops it
/// while keeping the two readable lines around it.
final _damaged = Note(
  id: 'n_damaged',
  title: 'Damaged note',
  content: [
    {'insert': 'Readable first line\n'},
    {'insert': 42},
    {'insert': 'Readable second line\n'},
  ],
  localVersion: 1,
  lastSyncedVersion: 1,
  syncStatus: SyncStatus.synced,
  createdAt: _day,
  updatedAt: _day,
);

final _intact = Note(
  id: 'n_intact',
  title: 'Intact note',
  content: [
    {'insert': 'All readable\n'},
  ],
  localVersion: 1,
  lastSyncedVersion: 1,
  syncStatus: SyncStatus.synced,
  createdAt: _day,
  updatedAt: _day,
);

void main() {
  // `saveNote(any())` needs a valid Note to stand in for.
  setUpAll(() => registerFallbackValue(_intact));

  Future<_Svc> pumpEditor(WidgetTester tester, {required Note note}) async {
    final svc = _Svc();
    when(
      svc.getAllNotes,
    ).thenAnswer((_) async => Success<List<Note>, NotesFailure>([note]));
    when(
      svc.getAllNotebooks,
    ).thenAnswer((_) async => const Success<List<Notebook>, NotesFailure>([]));
    when(
      () => svc.saveNote(any()),
    ).thenAnswer((_) async => const Success<void, NotesFailure>(null));

    final container = ProviderContainer(
      overrides: [
        notesServiceProvider.overrideWithValue(svc),
        userPreferencesProvider.overrideWithValue(await mockUserConfig()),
        currentDateProvider.overrideWithValue(_day),
      ],
    );
    addTearDown(container.dispose);
    await container.read(notesProvider.future);
    expect(container.read(noteByIdProvider(note.id)), isNotNull);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TranslationProvider(
          child: MaterialApp(
            theme: AppTheme.light(InkPalette.forest),
            localizationsDelegates: const [FlutterQuillLocalizations.delegate],
            home: NoteEditorScreen(noteId: note.id),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return svc;
  }

  group('a note with unreadable content', () {
    testWidgets('says so while it is open', (tester) async {
      await pumpEditor(tester, note: _damaged);

      expect(
        find.textContaining('1 item that this app cannot read'),
        findsOneWidget,
        reason: 'the count is the point - "something" is not actionable',
      );
    });

    testWidgets('pluralises the count', (tester) async {
      // Slang's plural map rather than an "item(s)" string, so a language with
      // more than two plural forms has something to choose from.
      await pumpEditor(tester, note: _damaged);

      expect(find.textContaining('1 item that'), findsOneWidget);
      expect(find.textContaining('1 items that'), findsNothing);
    });

    testWidgets('still shows the readable text', (tester) async {
      await pumpEditor(tester, note: _damaged);

      expect(find.byType(NoteEditorScreen), findsOneWidget);
      expect(find.byType(QuillEditor), findsOneWidget);
    });

    testWidgets('refuses to save until the loss is acknowledged', (
      tester,
    ) async {
      final svc = await pumpEditor(tester, note: _damaged);

      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle();

      expect(
        find.text('Some content could not be displayed'),
        findsOneWidget,
        reason: 'saving is the destructive act, so this is where to ask',
      );

      await tester.tap(find.text('Keep editing'));
      await tester.pumpAndSettle();

      verifyNever(() => svc.saveNote(any()));
    });

    testWidgets('discarding saves', (tester) async {
      // The other half of the gate. Without it the positive path is unproven
      // and a save could silently stop happening.
      //
      // There is no "does not ask twice" case, because a successful save pops
      // the editor: there is no second save in a session to suppress a prompt
      // for. Asserting one would have meant inventing the scenario.
      final svc = await pumpEditor(tester, note: _damaged);

      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Discard and save'));
      await tester.pumpAndSettle();

      verify(() => svc.saveNote(any())).called(1);
      expect(find.byType(NoteEditorScreen), findsNothing);
    });
  });

  group('a note with no unreadable content', () {
    testWidgets('does not warn', (tester) async {
      await pumpEditor(tester, note: _intact);

      expect(find.textContaining('cannot read'), findsNothing);
    });

    testWidgets('saves without a prompt', (tester) async {
      final svc = await pumpEditor(tester, note: _intact);

      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle();

      expect(
        find.text('Some content could not be displayed'),
        findsNothing,
        reason: 'warning on every save would train people to dismiss it',
      );
      verify(() => svc.saveNote(any())).called(1);
    });
  });

  group('a note that arrives after the first frame', () {
    // The case the controller swap exists for. The editor builds once with an
    // empty basic controller, renders it, and only then learns the note, so at
    // `_seedFrom` time the controller *is* held by a mounted widget.
    //
    // The production code assigns `controller.document` rather than disposing
    // and rebuilding, because disposing releases a controller the rendered tree
    // still holds. Be clear about what this test does and does not prove: it
    // pins that a late-arriving note re-seeds correctly and still warns, but it
    // does **not** fail on the old dispose-and-rebuild code. A widget test
    // rebuilds inside the same frame, so nothing ever touches the disposed
    // instance. The use-after-dispose needs a frame boundary, a gesture or an
    // animation between the dispose and the rebuild, which is reachable on a
    // device and not in here. The fix stands on the package's own API and on
    // reasoning, not on this assertion.
    testWidgets('re-seeds without disposing the controller in the tree', (
      tester,
    ) async {
      final svc = _Svc();
      final gate = Completer<List<Note>>();
      when(svc.getAllNotes).thenAnswer(
        (_) async => Success<List<Note>, NotesFailure>(await gate.future),
      );
      when(svc.getAllNotebooks).thenAnswer(
        (_) async => const Success<List<Notebook>, NotesFailure>([]),
      );

      final container = ProviderContainer(
        overrides: [
          notesServiceProvider.overrideWithValue(svc),
          userPreferencesProvider.overrideWithValue(await mockUserConfig()),
          currentDateProvider.overrideWithValue(_day),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: TranslationProvider(
            child: MaterialApp(
              theme: AppTheme.light(InkPalette.forest),
              localizationsDelegates: const [
                FlutterQuillLocalizations.delegate,
              ],
              home: NoteEditorScreen(noteId: _damaged.id),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(
        find.byType(NoteEditorScreen),
        findsOneWidget,
        reason: 'first frame renders before the note is known',
      );

      gate.complete([_damaged]);
      await container.read(notesProvider.future);
      await tester.pumpAndSettle();

      expect(find.byType(QuillEditor), findsOneWidget);
      expect(tester.takeException(), isNull);

      expect(
        find.textContaining('1 item that this app cannot read'),
        findsOneWidget,
        reason: 'and the content still seeds, warning included',
      );
    });
  });
}
