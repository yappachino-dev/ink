// The shell is the only frame in the app that can surface a refused vault
// push. The push runs from the auth navigator and from unlock, neither of which
// has a BuildContext, so without this the conflict is dropped silently and the
// device's unlock key never syncs.
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:ink/app/navigation/widgets/app_shell.dart';
import 'package:ink/core/domain/core_failure.dart';
import 'package:ink/core/presentation/navigation/app_destinations.dart';
import 'package:ink/core/presentation/theme/app_theme.dart';
import 'package:ink/core/presentation/theme/palettes.dart';
import 'package:ink/features/vault/domain/failures/vault_failure.dart';
import 'package:ink/features/vault/domain/vault_state.dart';
import 'package:ink/features/vault/presentation/notifiers/vault_notifier.dart';
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

/// Emits the given state once, reproducing the transition the notifier makes
/// when a push comes back refused.
class _ScriptedVaultState extends VaultNotifier {
  _ScriptedVaultState(this._target);

  final VaultState _target;

  @override
  VaultState build() {
    scheduleMicrotask(() => state = _target);
    return const VaultInitializing();
  }
}

void main() {
  Future<void> pump(WidgetTester tester, VaultState vaultState) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          vaultProvider.overrideWith(() => _ScriptedVaultState(vaultState)),
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
    await pump(tester, const VaultError(VaultKeyConflict()));

    expect(find.text(t.vault.errors.keyConflict), findsOneWidget);
  });

  testWidgets('a transient vault failure is not reported', (tester) async {
    await pump(tester, const VaultError(VaultCoreFailure(NetworkFailure())));

    expect(find.text(t.vault.errors.keyConflict), findsNothing);
  });

  testWidgets('the message says the vault already exists elsewhere', (
    tester,
  ) async {
    await pump(tester, const VaultError(VaultKeyConflict()));

    // The wording is the whole point: a bare "sync failed" leaves the user
    // retrying forever with no idea that this account is set up elsewhere.
    expect(
      find.textContaining('already has a vault on another device'),
      findsOneWidget,
    );
  });
}
