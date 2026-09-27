// Two things the Add notebook sheet got wrong.
//
// The colour row rendered eight identical empty circles: each swatch painted
// `context.ink.surface` and never the colour it stood for, so the palette was
// invisible and the sheet looked broken.
//
// Notebook marks were emoji, which render differently per platform, ignore the
// app's palette, and broke row alignment. They are Material glyphs now, keyed
// by a stable string because the value travels inside the encrypted payload.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ink/core/config/user_config.dart';
import 'package:ink/core/domain/result.dart';
import 'package:ink/core/domain/sync_status.dart';
import 'package:ink/core/presentation/extensions/bottom_sheet_extension.dart';
import 'package:ink/core/presentation/theme/app_theme.dart';
import 'package:ink/core/presentation/theme/palettes.dart';
import 'package:ink/features/notes/domain/entities/project.dart';
import 'package:ink/features/notes/domain/failures/notes_failure.dart';
import 'package:ink/features/notes/domain/notes_providers.dart';
import 'package:ink/features/notes/domain/notes_service.dart';
import 'package:ink/features/notes/presentation/constants/project_constants.dart';
import 'package:ink/features/notes/presentation/widgets/projects/create_project_sheet.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/test_helpers.dart';

class _Svc extends Mock implements NotesService {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      Project(
        id: 'fallback',
        title: 'fallback',
        emoji: 'book',
        colorValue: 0xFF000000,
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

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notesServiceProvider.overrideWithValue(svc),
          userPreferencesProvider.overrideWithValue(await mockUserConfig()),
        ],
        child: TranslationProvider(
          child: MaterialApp(
            theme: AppTheme.light(InkPalette.forest),
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () => context.showAppBottomSheetLayout<void>(
                      child: const CreateProjectSheet(),
                    ),
                    child: const Text('open'),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  /// The colours actually painted into the palette row, read off the widgets
  /// rather than off the list constant, so a regression in either fails here.
  Set<Color> paintedSwatchColors(WidgetTester tester) {
    final circles = tester
        .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
        .map((w) => w.decoration)
        .whereType<BoxDecoration>()
        .where((d) => d.shape == BoxShape.circle && d.color != null)
        .map((d) => d.color!)
        .toSet();

    return circles;
  }

  testWidgets('the colour row shows eight distinct colours', (tester) async {
    await pump(tester);

    final painted = paintedSwatchColors(tester);

    // Before: every swatch was the surface colour, so this collapsed to one.
    for (final color in projectColors) {
      expect(painted, contains(color), reason: 'swatch for $color is missing');
    }
    expect(
      painted.toSet().difference(projectColors.toSet()),
      hasLength(1),
      reason: 'only the "theme default" swatch may sit outside the palette',
    );
  });

  testWidgets('the swatches are not all the surface colour', (tester) async {
    await pump(tester);

    final painted = paintedSwatchColors(tester);
    final surface = Theme.of(
      tester.element(find.byType(CreateProjectSheet)),
    ).colorScheme.surface;

    // The one deliberate exception: the "use the theme default" swatch.
    expect(painted.where((c) => c == surface), hasLength(1));
  });

  group('notebook marks', () {
    test('every key resolves to its own icon', () {
      for (final candidate in projectIcons) {
        expect(projectIcon(candidate.key).icon, candidate.icon);
      }
    });

    test('keys are unique', () {
      final keys = projectIcons.map((i) => i.key).toSet();
      expect(keys, hasLength(projectIcons.length));
    });

    test('a legacy emoji degrades to a real icon, not a blank', () {
      // Notebooks created before this change store a glyph inside the
      // encrypted payload, so an unrecognised value is normal, not an error.
      for (final legacy in ['📋', '⭐', '🔥', '🛒', '']) {
        expect(projectIcon(legacy).icon, isNotNull);
        expect(projectIcon(legacy).icon, ProjectIcon.book.icon);
      }
    });

    test('an unknown future key also degrades', () {
      expect(projectIcon('not_a_real_key').icon, ProjectIcon.book.icon);
    });

    testWidgets('the picker offers one glyph per entry', (tester) async {
      await pump(tester);

      // `book` is the default, so it renders in its selected form; the rest
      // render unselected. Either way every entry has to be on screen.
      for (final candidate in projectIcons) {
        final offered =
            find.byIcon(candidate.icon).evaluate().isNotEmpty ||
            find.byIcon(candidate.selectedIcon).evaluate().isNotEmpty;
        expect(offered, isTrue, reason: '${candidate.key} is not offered');
      }
    });

    testWidgets('the name field previews an icon, not the stored key', (
      tester,
    ) async {
      await pump(tester);

      // The live preview printed the raw value into the field, so a new
      // notebook showed the word "book" where its mark should be.
      expect(find.text('book'), findsNothing);
      expect(find.byIcon(ProjectIcon.book.selectedIcon), findsWidgets);
    });

    testWidgets('no emoji is rendered in the picker', (tester) async {
      await pump(tester);

      // The old picker drew a Text per emoji. A Text styled as a glyph is gone.
      final glyphTexts = tester
          .widgetList<Text>(find.byType(Text))
          .where((t) => t.style?.fontSize == 20)
          .where(
            (t) => t.data?.runes.length == 1 && t.data!.runes.first > 0x2000,
          )
          .toList();

      expect(glyphTexts, isEmpty);
    });
  });
}
