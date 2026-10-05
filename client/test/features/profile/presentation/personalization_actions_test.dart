// The Personalization screen shipped four rows that did nothing, one of which
// opened a confirmation dialog for account deletion and then closed the dialog
// without deleting anything. These pin the fixed behaviour: deletion wipes,
// and the rows that are still unwired say so out loud.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:ink/core/presentation/theme/app_theme.dart';
import 'package:ink/core/presentation/theme/palettes.dart';
import 'package:ink/features/profile/presentation/screens/personalization_screen.dart';
import 'package:ink/features/vault/domain/vault_providers.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

class _VaultRecovery extends Mock implements VaultRecovery {}

void main() {
  late _VaultRecovery recovery;
  late GoRouter router;
  late int resets;

  setUp(() {
    recovery = _VaultRecovery();
    resets = 0;
    when(recovery.reset).thenAnswer((_) async {
      resets++;
    });
  });

  Future<void> pump(WidgetTester tester) async {
    router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, _) => const PersonalizationScreen()),
        GoRoute(path: '/welcome', builder: (_, _) => const Text('WELCOME')),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [vaultRecoveryProvider.overrideWithValue(recovery)],
        child: TranslationProvider(
          child: MaterialApp.router(
            theme: AppTheme.light(InkPalette.forest),
            routerConfig: router,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> confirmDelete(WidgetTester tester) async {
    await tester.tap(find.text(t.profile.account.delete));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, t.common.delete));
    await tester.pumpAndSettle();
  }

  testWidgets('confirming the wipe resets the vault', (tester) async {
    await pump(tester);
    await confirmDelete(tester);

    // The old handler popped the dialog and stopped. Nothing else in the app
    // makes key material unreadable, so a row-level delete would have left
    // recoverable ciphertext on disk.
    expect(resets, 1);

    // Leaving the user on a screen whose data no longer exists is the other
    // half of the bug: the router only re-evaluates its redirect on a
    // navigation, so without this the app keeps believing it has a vault.
    expect(find.text('WELCOME'), findsOneWidget);
  });

  testWidgets('cancelling the wipe changes nothing', (tester) async {
    await pump(tester);

    await tester.tap(find.text(t.profile.account.delete));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, t.common.cancel));
    await tester.pumpAndSettle();

    expect(resets, 0);
  });

  testWidgets('the unwired rows answer instead of swallowing the tap', (
    tester,
  ) async {
    await pump(tester);

    // An empty `onTap` renders identically to a working row. Each of these now
    // surfaces the refusal, which is the only honest option until the
    // endpoints exist.
    for (final title in [
      t.profile.personal.changeName,
      t.profile.personal.changePassword,
      t.profile.personal.changeEncryption,
    ]) {
      await tester.tap(find.text(title));
      await tester.pump();
      expect(find.text(t.common.notImplemented), findsOneWidget);
      await tester.pumpAndSettle();
    }
  });
}
