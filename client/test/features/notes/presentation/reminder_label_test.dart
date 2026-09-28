import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ink/core/presentation/theme/app_theme.dart';
import 'package:ink/core/presentation/theme/palettes.dart';
import 'package:ink/features/notes/presentation/helpers.dart';
import 'package:ink/features/notes/presentation/widgets/pickers/reminder_picker_sheet.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';

/// Regression: the reminder duration strings were authored as `"{n} minutes"`,
/// but slang interpolates with `{$n}`. A bare `{n}` is passed through untouched
/// by the generated plural resolver, so every preset over an hour read
/// literally as "{n} minutes" / "{n} hours" - the user saw the placeholder
/// twice in the picker and again on the chip, with no number anywhere.
void main() {
  final t = Translations();

  group('reminderLabel', () {
    test('substitutes the number rather than printing the placeholder', () {
      expect(reminderLabel(10, t), '10 minutes');
      expect(reminderLabel(30, t), '30 minutes');
      expect(reminderLabel(60, t), '1 hour');
      expect(reminderLabel(120, t), '2 hours');
      expect(reminderLabel(1440, t), '1 day');
      expect(reminderLabel(2880, t), '2 days');
    });

    test('never leaks a raw placeholder', () {
      for (final minutes in [0, 5, 10, 30, 45, 60, 90, 120, 1440, 2880]) {
        final label = reminderLabel(minutes, t);
        expect(
          label,
          isNot(contains('{')),
          reason: '"$minutes minutes" rendered as "$label"',
        );
        expect(label, isNot(contains(r'$n')));
      }
    });

    test('zero is "at time", not a duration', () {
      expect(reminderLabel(0, t), t.note.reminder.atTime);
    });
  });

  testWidgets('every duration the picker offers shows a real number', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: TranslationProvider(
          child: MaterialApp(
            theme: AppTheme.light(InkPalette.forest),
            home: const Scaffold(
              body: ReminderPickerSheet(current: null, onSelected: _ignore),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final labels = tester
        .widgetList<Text>(find.byType(Text))
        .map((w) => w.data ?? '')
        .where((d) => d.isNotEmpty)
        .toList();

    expect(labels, isNotEmpty, reason: 'the sheet rendered no labels at all');
    for (final label in labels) {
      expect(
        label,
        isNot(contains('{')),
        reason: 'the picker rendered the raw string "$label"',
      );
    }
  });
}

void _ignore(int? _) {}
