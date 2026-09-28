// Inbox removal.
//
// Inbox was a virtual "notebook" whose filter was `dueDate != null ||
// dueTime != null` — that is "has a deadline", which Today already answers, not
// an inbox. It also carried a long-press menu whose single action opened
// `CreateNotebookSheet(colorOnly: true)` with no `initialNotebook`, while that
// mode's confirm path dereferences `initialNotebook!`. Removing Inbox took all
// of that with it.
//
// These tests pin what the removal must keep true: the sheet can no longer
// reach a null notebook, and the drawer no longer offers an action for a lens.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ink/core/config/user_config.dart';
import 'package:ink/core/domain/result.dart';
import 'package:ink/core/domain/sync_status.dart';
import 'package:ink/core/presentation/theme/app_theme.dart';
import 'package:ink/core/presentation/theme/palettes.dart';
import 'package:ink/features/notes/domain/constants.dart';
import 'package:ink/features/notes/domain/entities/note.dart';
import 'package:ink/features/notes/domain/entities/notebook.dart';
import 'package:ink/features/notes/domain/failures/notes_failure.dart';
import 'package:ink/features/notes/domain/notes_providers.dart';
import 'package:ink/features/notes/domain/notes_service.dart';
import 'package:ink/features/notes/presentation/widgets/notebooks/create_notebook_sheet.dart';
import 'package:ink/features/notes/presentation/widgets/notebooks/drawer_virtual_notebook_item.dart';
import 'package:ink/features/notes/presentation/widgets/notebooks/notebook_item.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/test_helpers.dart';

class _Svc extends Mock implements NotesService {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      Notebook(
        id: 'fallback',
        title: 'F',
        emoji: 'x',
        colorValue: 0,
        localVersion: 1,
        lastSyncedVersion: 0,
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
      svc.getAllNotes,
    ).thenAnswer((_) async => const Success<List<Note>, NotesFailure>([]));
    when(
      svc.getAllNotebooks,
    ).thenAnswer((_) async => const Success<List<Notebook>, NotesFailure>([]));
    when(
      () => svc.saveNotebook(any()),
    ).thenAnswer((_) async => const Success<void, NotesFailure>(null));
  });

  Future<void> pumpSheet(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notesServiceProvider.overrideWithValue(svc),
          userPreferencesProvider.overrideWithValue(await mockUserConfig()),
        ],
        child: TranslationProvider(
          child: MaterialApp(
            theme: AppTheme.light(InkPalette.forest),
            home: const Scaffold(body: CreateNotebookSheet()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('the colour-only sheet mode is gone', () {
    // The crash this prevents: `CreateNotebookSheet(colorOnly: true)` has no
    // `initialNotebook`, and that mode's confirm did `initialNotebook!`.
    // With the mode removed, an empty-name confirm simply does nothing.
    testWidgets('confirming a new sheet with no name does not throw', (
      tester,
    ) async {
      await pumpSheet(tester);

      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      verifyNever(() => svc.saveNotebook(any()));
    });

    testWidgets('editing a notebook keeps the name, emoji and colour', (
      tester,
    ) async {
      final existing = Notebook(
        id: 'p1',
        title: 'Groceries',
        emoji: '🛒',
        colorValue: 0xFF112233,
        localVersion: 1,
        lastSyncedVersion: 1,
        syncStatus: SyncStatus.synced,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notesServiceProvider.overrideWithValue(svc),
            userPreferencesProvider.overrideWithValue(await mockUserConfig()),
          ],
          child: TranslationProvider(
            child: MaterialApp(
              theme: AppTheme.light(InkPalette.forest),
              home: Scaffold(
                body: CreateNotebookSheet(initialNotebook: existing),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.check));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      final saved =
          verify(() => svc.saveNotebook(captureAny())).captured.single
              as Notebook;
      expect(saved.title, 'Groceries');
      expect(saved.emoji, '🛒');
      expect(saved.id, 'p1');
    });
  });

  group('virtual drawer items are read-only', () {
    // The long-press menu existed only for Inbox, so it went with it. Today is
    // the only remaining virtual row.
    testWidgets('no long-press action is offered', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notesServiceProvider.overrideWithValue(svc),
            userPreferencesProvider.overrideWithValue(await mockUserConfig()),
          ],
          child: TranslationProvider(
            child: MaterialApp(
              theme: AppTheme.light(InkPalette.forest),
              home: const Scaffold(
                body: DrawerVirtualNotebookItem(
                  id: '__today__',
                  count: null,
                  title: 'Today',
                  icon: 'target',
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final item = tester.widget<NotebookItem>(find.byType(NotebookItem));
      expect(item.onLongPress, isNull);

      await tester.longPress(find.byType(NotebookItem));
      await tester.pumpAndSettle();

      // No context menu, and certainly no "edit" entry.
      expect(find.byIcon(Icons.edit_outlined), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tapping a virtual row selects it', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notesServiceProvider.overrideWithValue(svc),
            userPreferencesProvider.overrideWithValue(await mockUserConfig()),
          ],
          child: TranslationProvider(
            child: MaterialApp(
              theme: AppTheme.light(InkPalette.forest),
              home: Scaffold(
                body: DrawerVirtualNotebookItem(
                  id: todayNotebookId,
                  count: null,
                  title: 'Today',
                  icon: 'target',
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(NotebookItem));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('no inbox sentinel remains', () {
    test('the sentinel constant is gone from the domain', () {
      // Guards against it being reintroduced: the only two sentinels are the
      // "all" lens and "today".
      expect(todayNotebookId, '__today__');
      expect(<String>[
        allNotebooksId,
        todayNotebookId,
      ], isNot(contains('__inbox__')));
    });
  });
}
