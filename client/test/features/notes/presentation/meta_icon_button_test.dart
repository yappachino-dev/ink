// Step 9c, F-15: icon-only controls must have an accessible name.
//
// The audit found 2 `Semantics` nodes and 6 tooltips in the whole app, bare
// `GestureDetector`s as tap targets, and four unnamed buttons in a row in the
// editor's meta bar - a screen reader announced "button" four times with no way
// to tell them apart.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ink/core/presentation/theme/app_theme.dart';
import 'package:ink/core/presentation/theme/palettes.dart';
import 'package:ink/features/notes/presentation/widgets/notes/editor/meta_icon_button.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(
      ProviderScope(
        child: TranslationProvider(
          child: MaterialApp(
            theme: AppTheme.light(InkPalette.forest),
            home: Scaffold(body: child),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('an icon-only meta button', () {
    testWidgets('is named, and is a real button', (tester) async {
      await pump(
        tester,
        const MetaIconButton(
          icon: Icons.calendar_today_outlined,
          tooltip: 'Due date',
          onTap: _noop,
        ),
      );

      // Material supplies focus, a ripple, a tooltip and the minimum tap
      // target. A bare GestureDetector wrapping the Icon supplied none of them,
      // which is why the tooltip is now a required argument.
      expect(find.byType(IconButton), findsOneWidget);
      expect(find.byTooltip('Due date'), findsOneWidget);

      final node = tester.getSemantics(find.byType(MetaIconButton));
      expect(node.label, contains('Due date'));
      expect(
        node.getSemanticsData().flagsCollection.isButton,
        isTrue,
        reason: 'it is announced as a plain label, not a control',
      );
    });

    testWidgets('carries its value into the name once set', (tester) async {
      await pump(
        tester,
        const MetaIconButton(
          icon: Icons.calendar_today_outlined,
          tooltip: 'Due date',
          label: '14 January',
          isActive: true,
          onTap: _noop,
        ),
      );

      final node = tester.getSemantics(find.byType(MetaIconButton));
      expect(node.label, contains('Due date'));
      expect(node.label, contains('14 January'));
    });

    testWidgets('names the clear affordance separately', (tester) async {
      await pump(
        tester,
        const MetaIconButton(
          icon: Icons.calendar_today_outlined,
          tooltip: 'Due date',
          label: '14 January',
          isActive: true,
          onTap: _noop,
          onClear: _noop,
        ),
      );

      // Two actions in one row must be two focus stops, each with its own
      // name, or the clear button is unreachable by name.
      expect(find.byType(IconButton), findsOneWidget);
      expect(find.byTooltip(t.common.remove), findsOneWidget);
    });
  });
}

void _noop() {}
