// The note row is a button that contains a checkbox, which is the one shape in
// the app where the semantics tree can go quietly wrong.
//
// It was: `Semantics(button: true, label: note.title)` wrapping a subtree that
// already renders the title as a Text. The two labels merged, so every row
// announced as "My note, My note"; and because the wrapper was not a container,
// the checkbox became a *child* of the button node rather than its own target.
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ink/core/domain/result.dart';
import 'package:ink/core/domain/sync_status.dart';
import 'package:ink/core/presentation/theme/app_theme.dart';
import 'package:ink/core/presentation/theme/palettes.dart';
import 'package:ink/features/notes/domain/entities/note.dart';
import 'package:ink/features/notes/domain/entities/notebook.dart';
import 'package:ink/features/notes/domain/failures/notes_failure.dart';
import 'package:ink/features/notes/domain/notes_providers.dart';
import 'package:ink/features/notes/domain/notes_service.dart';
import 'package:ink/features/notes/presentation/widgets/notes/card/active_note_card.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

class _Svc extends Mock implements NotesService {}

final _note = Note(
  id: 'n1',
  title: 'My note',
  content: [
    {'insert': 'Body text\n'},
  ],
  localVersion: 1,
  lastSyncedVersion: 1,
  syncStatus: SyncStatus.synced,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

void main() {
  late _Svc svc;

  setUp(() {
    svc = _Svc();
    when(
      svc.getAllNotebooks,
    ).thenAnswer((_) async => const Success<List<Notebook>, NotesFailure>([]));
  });

  Future<void> pump(WidgetTester tester, {required bool showCompletion}) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [notesServiceProvider.overrideWithValue(svc)],
        child: TranslationProvider(
          child: MaterialApp(
            theme: AppTheme.light(InkPalette.forest),
            home: Scaffold(
              body: ActiveNoteCard(
                note: _note,
                onTap: () {},
                showCompletion: showCompletion,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('the row announces its title once, not twice', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(tester, showCompletion: true);

    final label = tester.getSemantics(find.byType(ActiveNoteCard)).label;

    // Once. The row is named by its own content - the title and the preview -
    // which is what someone scanning the list actually wants to hear.
    expect(label, 'My note\nBody text');
    expect(
      RegExp('My note').allMatches(label).length,
      1,
      reason:
          'the wrapper label merged with the title Text, so every row '
          'announced the same title twice',
    );
    handle.dispose();
  });

  testWidgets('the row is a button that reports a tap', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(tester, showCompletion: true);

    // Every structural attempt to lift the checkbox out - `container`,
    // `explicitChildNodes`, an explicit `onTap` - split the row's own tap into
    // a child node and left the row announced as a button with no action. The
    // merged node has to stay actionable, so this is the assertion that stops
    // that being reintroduced.
    final node = tester.getSemantics(find.byType(ActiveNoteCard));
    expect(node.flagsCollection.isButton, isTrue);
    expect(
      node.getSemanticsData().hasAction(SemanticsAction.tap),
      isTrue,
      reason: 'the row must be actionable in its own right',
    );
    handle.dispose();
  });

  testWidgets('the checkbox stays its own actionable target', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(tester, showCompletion: true);

    // Reachable and tappable on its own, so a screen reader user can tick a
    // note without opening it - which is the whole reason the checkbox is here
    // rather than buried in the note details sheet.
    final box = tester.getSemantics(find.byType(Checkbox));
    final data = box.getSemanticsData();
    expect(data.hasAction(SemanticsAction.tap), isTrue);
    expect(box.flagsCollection.isChecked, isNotNull);
    handle.dispose();
  });
}
