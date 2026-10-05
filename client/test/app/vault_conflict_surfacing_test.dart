// The shell is the only frame in the app that can surface a refused vault
// push. The push runs from the auth navigator and from unlock, neither of which
// has a BuildContext, so without this the conflict is dropped silently and the
// device's unlock key never syncs.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:ink/app/navigation/widgets/app_shell.dart';
import 'package:ink/core/domain/core_failure.dart';
import 'package:ink/core/presentation/navigation/app_destinations.dart';
import 'package:ink/core/presentation/theme/app_theme.dart';
import 'package:ink/core/presentation/theme/palettes.dart';
import 'package:ink/features/vault/domain/failures/vault_failure.dart';
import 'package:ink/features/vault/presentation/notifiers/vault_conflict_notifier.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';

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
                builder: (_, _) => const SizedBox.shrink(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppDestinations.calendar,
                builder: (_, _) => const SizedBox.shrink(),
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

/// Holds the conflict the way the notifier does once a push comes back
/// refused: already set when the shell mounts.
class _FixedConflict extends VaultConflictNotifier {
  _FixedConflict(this._value);

  final VaultFailure? _value;

  @override
  VaultFailure? build() => _value;
}

void main() {
  Future<void> pump(WidgetTester tester, VaultFailure? conflict) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          if (conflict != null)
            vaultConflictProvider.overrideWith(() => _FixedConflict(conflict)),
        ],
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

  testWidgets('a refused vault push is reported to the user', (tester) async {
    await pump(tester, const VaultKeyConflict());

    expect(find.text(t.vault.errors.keyConflict), findsOneWidget);
  });

  testWidgets('it is reported when the conflict predates the mount', (
    tester,
  ) async {
    // The push starts in the auth navigator, so it can resolve before the
    // shell mounts. Listening for transitions would drop it; reading the
    // current value does not.
    await pump(tester, const VaultKeyConflict());

    expect(find.text(t.vault.errors.keyConflict), findsOneWidget);
  });

  testWidgets('a transient vault failure is not reported', (tester) async {
    await pump(tester, const VaultCoreFailure(NetworkFailure()));

    expect(find.text(t.vault.errors.keyConflict), findsNothing);
  });

  testWidgets('the message says the vault already exists elsewhere', (
    tester,
  ) async {
    await pump(tester, const VaultKeyConflict());

    // The wording is the whole point: a bare "sync failed" leaves the user
    // retrying forever with no idea that this account is set up elsewhere.
    expect(
      find.textContaining('already has a vault on another device'),
      findsOneWidget,
    );
  });

  testWidgets('no conflict means no snackbar', (tester) async {
    await pump(tester, null);

    expect(find.byType(SnackBar), findsNothing);
  });
}
