// Step 9c, F-16: vault creation spans five screens with no position marker.
//
// The flow creates an encryption key and then asks the user to write down a
// recovery phrase, so "how much is left" and "which step matters" are both real
// questions, not decoration.
import 'package:flutter_test/flutter_test.dart';
import 'package:ink/core/presentation/theme/app_theme.dart';
import 'package:ink/core/presentation/theme/palettes.dart';
import 'package:ink/features/vault/presentation/widgets/setup_progress.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Future<void> pump(
    WidgetTester tester, {
    required int step,
    int total = 4,
  }) async {
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          theme: AppTheme.light(InkPalette.forest),
          home: Scaffold(
            body: SetupProgress(step: step, total: total),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('it states the position', (tester) async {
    await pump(tester, step: 2);

    expect(
      find.text(t.vault.progressStep(current: 2, total: 4)),
      findsOneWidget,
    );
  });

  testWidgets('it states what is left', (tester) async {
    await pump(tester, step: 2);

    expect(find.text(t.vault.progressRemaining(count: 2)), findsOneWidget);
  });

  testWidgets('the final step says so rather than "0 left"', (tester) async {
    await pump(tester, step: 4);

    // "0 left" reads as broken, and there is nothing after this step.
    expect(find.text(t.vault.progressLast), findsOneWidget);
    expect(find.text(t.vault.progressRemaining(count: 0)), findsNothing);
  });

  testWidgets('one segment per step, filled up to the current one', (
    tester,
  ) async {
    await pump(tester, step: 3);

    final bars = tester.widgetList<AnimatedContainer>(
      find.byType(AnimatedContainer),
    );
    expect(bars, hasLength(4));

    final theme = AppTheme.light(InkPalette.forest);
    final done = bars
        .map((b) => b.decoration)
        .whereType<BoxDecoration>()
        .where((d) => d.color == theme.colorScheme.primary);
    expect(done, hasLength(3));
  });

  testWidgets('it is announced as a single labelled node', (tester) async {
    await pump(tester, step: 2);

    // The two labels must not be read out as unrelated fragments.
    final node = tester.getSemantics(find.byType(SetupProgress));
    expect(node.label, contains('2'));
    expect(node.label, contains('4'));
  });

  testWidgets('the semantic label carries the remaining count, not just the '
      'position', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(tester, step: 2);

    // The two visible labels are deliberately not announced as fragments, so
    // the container's own label is the only thing a screen reader reaches. It
    // used to be "Step 2 of 4" alone, which silently dropped "2 left" - the
    // half that says whether to keep going.
    final node = tester.getSemantics(find.byType(SetupProgress));
    final spoken = node.label;

    expect(
      spoken,
      contains(t.vault.progressStep(current: 2, total: 4)),
      reason: 'the position must be announced',
    );
    expect(
      spoken,
      contains(t.vault.progressRemaining(count: 2)),
      reason: 'the remaining count was being silenced entirely',
    );
    handle.dispose();
  });

  testWidgets('the last step announces that it is the last', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(tester, step: 4);

    final spoken = tester.getSemantics(find.byType(SetupProgress)).label;
    expect(spoken, contains(t.vault.progressLast));
    handle.dispose();
  });
}
