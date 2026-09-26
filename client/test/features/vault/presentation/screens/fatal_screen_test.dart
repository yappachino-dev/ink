import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ink/core/presentation/theme/app_theme.dart';
import 'package:ink/core/presentation/theme/palettes.dart';
import 'package:ink/features/vault/domain/vault_providers.dart';
import 'package:ink/features/vault/presentation/screens/fatal_screen.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

class _MockVaultRecovery extends Mock implements VaultRecovery {}

void main() {
  // `VaultRecovery.reset()` drops the local database, zeroes the sync
  // cursor and clears both tokens. Note content is end-to-end encrypted, so
  // there is no server-side copy and the action cannot be undone. It is
  // therefore gated behind `kDebugMode`, which is a compile-time constant: in
  // a release build the branch is removed and the screen offers only a
  // non-destructive hint.
  //
  // Widget tests always run in debug, so these cannot observe a release build.
  // What they do pin down is that the debug branch is the active one, that its
  // label is localized rather than a hardcoded literal, and that the two
  // branches are not transposed.
  group('FatalScreen', () {
    Future<void> pumpFatalScreen(WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            vaultRecoveryProvider.overrideWithValue(_MockVaultRecovery()),
          ],
          child: TranslationProvider(
            child: MaterialApp(
              theme: AppTheme.light(InkPalette.forest),
              home: const FatalScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets(
      'shows the debug-only reset control, labelled from i18n',
      (tester) async {
        await pumpFatalScreen(tester);

        expect(find.text(t.vault.fatal.devReset), findsOneWidget);

        // The old control was a hardcoded English literal, which is how an
        // untranslated destructive action survived in the UI. Assert the
        // literal is gone so it cannot come back.
        expect(find.text('Reset the app state'), findsNothing);
      },
    );

    testWidgets(
      'never presents the release hint in a debug build',
      (tester) async {
        await pumpFatalScreen(tester);

        expect(find.text(t.vault.fatal.releaseHint), findsNothing);
      },
    );
  });
}
