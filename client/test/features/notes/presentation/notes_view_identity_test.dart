// Regression: `ValueKey(viewState)` keyed an `AnimatedSwitcher` on instance
// identity. `notebookNotesProvider` returns a fresh list on every rebuild, so
// every edit and every sync produced a new `NotesViewContent`, the switcher
// treated it as a different child, and the list was torn down and rebuilt —
// resetting scroll to the top mid-read.
//
// The test scrolls, changes the notes, and asserts the offset survived. It
// drives the real `NotesViewState.switcherKey` rather than restating the
// expression, so production and test cannot drift apart.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ink/core/config/user_config.dart';
import 'package:ink/core/domain/result.dart';
import 'package:ink/core/domain/sync_status.dart';
import 'package:ink/core/presentation/app_animations.dart';
import 'package:ink/core/presentation/theme/app_theme.dart';
import 'package:ink/core/presentation/theme/palettes.dart';
import 'package:ink/features/notes/domain/constants.dart';
import 'package:ink/features/notes/domain/entities/note.dart';
import 'package:ink/features/notes/domain/entities/notebook.dart';
import 'package:ink/features/notes/domain/failures/notes_failure.dart';
import 'package:ink/features/notes/domain/notes_providers.dart';
import 'package:ink/features/notes/domain/notes_service.dart';
import 'package:ink/features/notes/domain/task_priority.dart';
import 'package:ink/features/notes/presentation/notifiers/notes_notifier.dart';
import 'package:ink/features/notes/presentation/notifiers/providers/notes_view_state_provider.dart';
import 'package:ink/features/notes/presentation/notifiers/ui_state.dart';
import 'package:ink/features/notes/presentation/widgets/notes/notes_view.dart';
import 'package:ink/features/notes/presentation/widgets/notes/notes_view_state.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Svc extends Mock implements NotesService {}

class _AllSelected extends SelectedNotebookId {
  @override
  String build() => allNotebooksId;
}

Note _note(String id, {int touch = 0}) => Note(
  id: id,
  title: 'title $id',
  content: [
    {'insert': 'body $id\n'},
  ],
  localVersion: 1 + touch,
  lastSyncedVersion: 1 + touch,
  syncStatus: SyncStatus.synced,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026).add(Duration(minutes: touch)),
  notebookId: 'p1',
  priority: TaskPriority.medium,
);

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    registerFallbackValue(_note('fallback'));
  });

  late _Svc svc;
  late SharedPreferences prefs;

  setUp(() async {
    svc = _Svc();
    prefs = await SharedPreferences.getInstance();
    when(
      svc.getAllNotebooks,
    ).thenAnswer((_) async => const Success<List<Notebook>, NotesFailure>([]));
  });

  Future<ProviderContainer> containerOf(List<Note> notes) async {
    when(
      svc.getAllNotes,
    ).thenAnswer((_) async => Success<List<Note>, NotesFailure>(notes));
    final c = ProviderContainer(
      overrides: [
        notesServiceProvider.overrideWithValue(svc),
        userPreferencesProvider.overrideWithValue(UserConfig(prefs)),
        currentDateProvider.overrideWithValue(DateTime(2026)),
        selectedNotebookIdProvider.overrideWith(_AllSelected.new),
      ],
    );
    addTearDown(c.dispose);
    final sub = c.listen(notesViewStateProvider, (_, _) {});
    addTearDown(sub.close);
    await c.read(notesProvider.future);
    return c;
  }

  Future<void> pumpSurface(WidgetTester tester, ProviderContainer c) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: c,
        child: TranslationProvider(
          child: MaterialApp(
            theme: AppTheme.light(InkPalette.forest),
            home: Scaffold(
              body: SizedBox(
                height: 400,
                child: AnimatedSwitcher(
                  duration: AppDurations.sheet,
                  child: NotesView(
                    key: ValueKey(c.read(notesViewStateProvider).switcherKey),
                    state: c.read(notesViewStateProvider),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('the switcher key is the type, not the instance', () {
    test('two different content states share a key', () {
      // No `==` override on NotesViewState, so these are distinct objects.
      final a = NotesViewContent([_note('a')]);
      final b = NotesViewContent([_note('a', touch: 1)]);

      expect(a, isNot(equals(b)), reason: 'instances are distinct');
      expect(a.switcherKey, b.switcherKey);
    });

    test('different states still get different keys', () {
      expect(
        const NotesViewContent([]).switcherKey,
        isNot(const NotesViewEmpty().switcherKey),
      );
      expect(
        const NotesViewEmpty().switcherKey,
        isNot(const NotesViewEmptyByFilter().switcherKey),
      );
      expect(
        const NotesViewEmpty().switcherKey,
        isNot(const NotesViewLoading().switcherKey),
      );
    });
  });

  testWidgets('scroll position survives a data change', (tester) async {
    // Enough notes to overflow a 400px box.
    final many = List.generate(20, (i) => _note('n$i'));
    final c = await containerOf(many);

    await pumpSurface(tester, c);

    final scrollable = find.byType(Scrollable).first;
    await tester.drag(scrollable, const Offset(0, -600));
    await tester.pumpAndSettle();

    final before = tester.state<ScrollableState>(scrollable).position.pixels;
    expect(
      before,
      greaterThan(0),
      reason: 'the list must actually be scrolled',
    );

    // Same notes, one of them touched: a new list, a new state instance, the
    // same state *type*. This is what an edit and every sync produce.
    when(svc.getAllNotes).thenAnswer(
      (_) async => Success<List<Note>, NotesFailure>(
        List.generate(20, (i) => _note('n$i', touch: 1)),
      ),
    );
    c.invalidate(notesProvider);
    await pumpSurface(tester, c);

    final after = tester.state<ScrollableState>(scrollable).position.pixels;

    expect(
      after,
      before,
      reason: 'a same-type state must update in place, not remount the list',
    );
  });

  testWidgets('a genuine state change still animates', (tester) async {
    final c = await containerOf([_note('a')]);
    await pumpSurface(tester, c);
    expect(find.text('title a'), findsOneWidget);

    when(
      svc.getAllNotes,
    ).thenAnswer((_) async => const Success<List<Note>, NotesFailure>([]));
    c.invalidate(notesProvider);
    await tester.pumpAndSettle();
    await pumpSurface(tester, c);

    // Content -> Empty is a different type, so the switcher may cross-fade and
    // the empty copy must replace the list.
    expect(find.text(t.notes.emptyTitle), findsOneWidget);
    expect(find.text('title a'), findsNothing);
  });
}
