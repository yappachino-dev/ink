// The Date and time sheet read a `late` field that nothing ever assigned, so
// opening it threw before the first frame completed. The dialog now exists and
// persists its choice.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ink/core/config/user_config.dart';
import 'package:ink/core/presentation/extensions/bottom_sheet_extension.dart';
import 'package:ink/core/presentation/theme/app_theme.dart';
import 'package:ink/core/presentation/theme/palettes.dart';
import 'package:ink/features/profile/presentation/widgets/options/timezone_sheet.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  Future<UserConfig> pump(WidgetTester tester) async {
    final config = await mockUserConfig();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [userPreferencesProvider.overrideWithValue(config)],
        child: TranslationProvider(
          child: MaterialApp(
            theme: AppTheme.light(InkPalette.forest),
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () => context.showAppBottomSheetLayout<void>(
                      child: const TimezoneSheet(),
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
    return config;
  }

  testWidgets('it opens without throwing', (tester) async {
    await pump(tester);

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(TimezoneSheet), findsOneWidget);
    expect(find.text(t.profile.settings.timezone), findsOneWidget);
    expect(find.text(t.common.save), findsOneWidget);
  });

  testWidgets('a choice is written through to storage', (tester) async {
    final config = await pump(tester);

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text(t.timezones.warsaw).last);
    await tester.pumpAndSettle();

    await tester.tap(find.text(t.common.save));
    await tester.pumpAndSettle();

    expect(config.selectedTimezone, 'warsaw');
  });
}
