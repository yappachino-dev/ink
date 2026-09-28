// Step 9c, F-15: icon-only controls must have an accessible name.
//
// The audit found 2 `Semantics` nodes and 6 tooltips in the whole app, bare
// `GestureDetector`s as tap targets, and four unnamed buttons in a row in the
// editor's meta bar - a screen reader announced "button" four times with no way
// to tell them apart.
import 'package:flutter/semantics.dart';
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

      // Found by label rather than by widget type: the chip is a Container
      // holding two sibling semantics nodes (the value, and the clear
      // affordance when present), so the labelled node is not the widget's own
      // boundary. Two actions in one control must be two focus stops.
      final node = tester.getSemantics(
        find.bySemanticsLabel(RegExp('Due date')),
      );
      expect(node.label, contains('Due date'));
      expect(node.label, contains('14 January'));
      // A button with no tap action is announced but does nothing.
      expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
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
      // name, or the clear button is unreachable by name. The clear control is
      // no longer an IconButton (see MetaIconButton for why), so it is found
      // by its tooltip and by its semantics instead.
      // Asserted property by property rather than with matchesSemantics: the
      // exhaustive matcher also pins focus/longPress, which come and go with
      // tooltip plumbing and are not what this test is about.
      final clear = tester.getSemantics(find.bySemanticsLabel(t.common.remove));
      expect(clear.label, t.common.remove);
      expect(clear.getSemanticsData().flagsCollection.isButton, isTrue);
      expect(clear.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
      // Both actions survive as separate, separately named stops. The chip's
      // own node used to exclude its descendants, which is how the clear
      // control became unreachable by name.
      expect(find.bySemanticsLabel(t.common.remove), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('Due date')), findsOneWidget);
    });
  });

  group('a labelled meta button', () {
    // The clear button used to carry the full 44px tap target, and because the
    // chip sizes to its tallest child that made every *set* field 52px tall -
    // taller than the 32px Quill toolbar button sitting directly above it. The
    // row read as a row of chunky chips instead of one strip of editor chrome.
    testWidgets('stays in step with the toolbar it sits under', (tester) async {
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

      final height = tester.getSize(find.byType(MetaIconButton)).height;

      expect(
        height,
        lessThanOrEqualTo(40),
        reason: 'the chip is taller than the toolbar it sits under',
      );
      // And it must not have collapsed into something untappable.
      expect(height, greaterThanOrEqualTo(28));
    });
  });
}

void _noop() {}
