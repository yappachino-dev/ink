// Step 9a: the navigation shell.
//
// F-09 was three bare icons in a row with no labels and equal visual weight.
// F-10 was every tab switch being a `context.go()` against a flat route list,
// so leaving a tab discarded its scroll position, its open sheets and its local
// state.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:ink/app/navigation/widgets/app_shell.dart';
import 'package:ink/core/config/user_config.dart';
import 'package:ink/core/presentation/navigation/app_destinations.dart';
import 'package:ink/core/presentation/theme/app_theme.dart';
import 'package:ink/core/presentation/theme/palettes.dart';
import 'package:ink/features/notes/domain/notes_lens.dart';
import 'package:ink/features/notes/presentation/notifiers/ui_state.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';

import '../../../helpers/test_helpers.dart';

GoRouter _shellRouter() {
  return GoRouter(
    initialLocation: AppDestinations.notes,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppDestinations.notes,
                builder: (_, _) => const _Counter(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppDestinations.calendar,
                builder: (_, _) => const _Text(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppDestinations.profile,
                builder: (_, _) => const SizedBox.shrink(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

void main() {
  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: TranslationProvider(
          child: MaterialApp.router(
            theme: AppTheme.light(InkPalette.forest),
            routerConfig: _shellRouter(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('every destination is labelled (F-09)', (tester) async {
    await pump(tester);

    // The old bar hid both label sets, leaving a checkbox glyph that required
    // guessing.
    expect(find.text(t.note.title), findsOneWidget);
    expect(find.text(t.calendar.title), findsOneWidget);
    expect(find.text(t.profile.title), findsOneWidget);
  });

  testWidgets('it is a Material 3 bar, not a rounded sheet (F-09)', (
    tester,
  ) async {
    await pump(tester);

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsNothing);
  });

  testWidgets('a branch keeps its state across a tab switch (F-10)', (
    tester,
  ) async {
    await pump(tester);

    expect(find.text('taps: 0'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.text('taps: 1'), findsOneWidget);

    // Leave for Calendar and come back.
    await tester.tap(find.text(t.calendar.title));
    await tester.pumpAndSettle();
    expect(find.byType(_Text), findsOneWidget);

    await tester.tap(find.text(t.note.title));
    await tester.pumpAndSettle();

    // A flat `go()` would have rebuilt the screen and reset the counter to 0.
    expect(find.text('taps: 1'), findsOneWidget);
  });

  testWidgets('a text field keeps what was typed (F-10)', (tester) async {
    await pump(tester);

    await tester.tap(find.text(t.calendar.title));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'half-written thought');
    await tester.pumpAndSettle();

    await tester.tap(find.text(t.profile.title));
    await tester.pumpAndSettle();
    await tester.tap(find.text(t.calendar.title));
    await tester.pumpAndSettle();

    expect(find.text('half-written thought'), findsOneWidget);
  });

  testWidgets('switching to Calendar leaves the Notes lens untouched', (
    tester,
  ) async {
    // The shell used to clear a Today lens on entering Calendar, because both
    // screens read one shared selection and only Notes understood Today.
    // Calendar is a date index and reads no lens, so a tab switch has no reason
    // to mutate another branch's state.
    final container = ProviderContainer(
      overrides: [
        userPreferencesProvider.overrideWithValue(await mockUserConfig()),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TranslationProvider(
          child: MaterialApp.router(
            theme: AppTheme.light(InkPalette.forest),
            routerConfig: _shellRouter(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await container
        .read(notesLensSelectionProvider.notifier)
        .select(const NotesLens.today());

    // Assert the premise before the action. This test previously passed while
    // asserting `all == all`: the selection had never taken effect, so it
    // verified nothing.
    expect(container.read(notesLensSelectionProvider), const NotesLens.today());
    expect(find.byType(TextField), findsNothing);

    await tester.tap(find.text(t.calendar.title).last);
    await tester.pumpAndSettle();

    // The Calendar branch really is showing, so the switch happened.
    expect(find.byType(TextField), findsOneWidget);
    expect(container.read(notesLensSelectionProvider), const NotesLens.today());
  });
}

class _Counter extends StatefulWidget {
  const _Counter();

  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  int _taps = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('taps: $_taps'),
            IconButton(
              onPressed: () => setState(() => _taps++),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}

class _Text extends StatefulWidget {
  const _Text();

  @override
  State<_Text> createState() => _TextState();
}

class _TextState extends State<_Text> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: TextField(controller: _controller)),
    );
  }
}
