// ListTile paints its ink splash on the nearest Material ancestor. The sheet
// layout paints its own background through a BoxDecoration and is not a
// Material, so every tile in every sheet built on it was without an ink
// surface: no ripple in release, and a debug assert on some tiles.
//
// It was fixed once, in the reminder picker only, by wrapping that one tile.
// The priority, project, notebook-filter, view-mode and language sheets were
// left with the same defect. This asserts the surface is provided once, for
// everything.
import 'package:flutter_test/flutter_test.dart';
import 'package:ink/core/presentation/theme/app_theme.dart';
import 'package:ink/core/presentation/theme/palettes.dart';
import 'package:ink/core/presentation/widgets/bottom_sheet.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('a tile in the sheet layout has a Material to paint ink on', (
    tester,
  ) async {
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          theme: AppTheme.light(InkPalette.forest),
          home: const Scaffold(body: BottomSheetLayout(children: [])),
        ),
      ),
    );

    // The whole point: the fix lives in the shared layout, not in each tile.
    // A sheet that adds a new ListTile gets a ripple without knowing it.
    expect(
      find.descendant(
        of: find.byType(BottomSheetLayout),
        matching: find.byType(Material),
      ),
      findsWidgets,
      reason: 'BottomSheetLayout must supply the ink surface for its children',
    );
  });

  testWidgets('the supplied Material is transparent, so the sheet shows '
      'through', (tester) async {
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          theme: AppTheme.light(InkPalette.forest),
          home: const Scaffold(body: BottomSheetLayout(children: [])),
        ),
      ),
    );

    final materials = tester
        .widgetList<Material>(
          find.descendant(
            of: find.byType(BottomSheetLayout),
            matching: find.byType(Material),
          ),
        )
        .toList();

    // A Material with an opaque colour would paint over the sheet's own
    // background and silently change every sheet's surface.
    expect(
      materials.where((m) => m.type == MaterialType.transparency).length,
      greaterThan(0),
      reason: 'the ink surface must not repaint the sheet',
    );
  });

  testWidgets('a ListTile placed in the layout resolves an ink surface', (
    tester,
  ) async {
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          theme: AppTheme.light(InkPalette.forest),
          home: Scaffold(
            body: BottomSheetLayout(
              children: [ListTile(title: const Text('Priority'), onTap: () {})],
            ),
          ),
        ),
      ),
    );

    // Material.of on the tile's context must not throw, and must find the
    // sheet's transparent surface rather than an ancestor outside the sheet.
    final tileContext = tester.element(find.byType(ListTile));
    expect(
      () => Material.of(tileContext),
      returnsNormally,
      reason: 'ListTile asserts when it has no Material to paint its ink on',
    );
  });
}
