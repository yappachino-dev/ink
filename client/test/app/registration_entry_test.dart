// Two regressions from the first cut of the Profile registration entry.
//
// 1. The row said "Create account" and opened the sign-in screen. Anyone
//    without an account is by definition not signing in.
// 2. The row stayed live after registering. `localOnly` is a synchronous getter
//    over SharedPreferences, so the write notified nothing, and AppShell keeps
//    its branches in an IndexedStack, so switching tabs did not rebuild it.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:ink/app/init.dart';
import 'package:ink/core/presentation/navigation/app_destinations.dart';
import 'package:ink/core/presentation/providers/status_providers.dart';
import 'package:ink/core/presentation/theme/app_theme.dart';
import 'package:ink/core/presentation/theme/palettes.dart';
import 'package:ink/features/auth/domain/auth_preferences.dart';
import 'package:ink/features/profile/presentation/screens/profile_screen.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  SharedPreferences.setMockInitialValues({});

  late SharedPreferences shared;
  late ProviderContainer container;

  setUp(() async {
    shared = await SharedPreferences.getInstance();
    await shared.clear();

    container = ProviderContainer(
      // The real composition root, so this exercises the production adapter
      // rather than a local stand-in that could drift from it.
      overrides: [
        ...buildOverrides(shared),
        isOfflineProvider.overrideWithValue(false),
        syncActivityProvider.overrideWithValue(SyncActivity.idle),
      ],
    );
    addTearDown(container.dispose);
  });

  /// The production adapter, not a reimplementation of it. A local stand-in
  /// would keep passing if the invalidation inside `_AuthPreferencesAdapter`
  /// were deleted.
  Future<void> setLocalOnly({required bool local}) =>
      container.read(authPreferencesProvider).setLocalOnly(local: local);

  Future<void> pumpProfile(WidgetTester tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const ProfileScreen()),
        GoRoute(path: '/auth', builder: (_, _) => const Text('SIGN IN')),
        // Route markers, not the real screens. Importing the auth feature's
        // presentation layer from a profile test is exactly what the
        // architecture checker forbids, and the bug was the destination
        // anyway - not what that destination renders.
        GoRoute(
          path: '/auth/register',
          builder: (_, _) => const Text('REGISTER'),
        ),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
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

  testWidgets('"Create account" opens registration, not sign-in', (
    tester,
  ) async {
    await pumpProfile(tester);

    await tester.tap(find.text(t.profile.account.create));
    await tester.pumpAndSettle();

    expect(find.text('REGISTER'), findsOneWidget);
    expect(find.text('SIGN IN'), findsNothing);
  });

  testWidgets('the row is gone once the account exists', (tester) async {
    // Build the adapter before the screen so the later read cannot be what
    // triggers the rebuild.
    container.read(authPreferencesProvider);
    await pumpProfile(tester);

    expect(find.text(t.profile.account.create), findsOneWidget);

    await setLocalOnly(local: false);
    await tester.pump();
    await tester.pumpAndSettle();

    // No restart, no tab switch. If this needs a cold start to observe, the
    // write is still invisible and the row is still tappable.
    expect(find.text(t.profile.account.create), findsNothing);
  });

  test('the destination carries the in-app source', () {
    // The register screen routes its own escape hatch on `source`, so the
    // constant has to keep it or a user who does have an account gets
    // onboarding behaviour.
    expect(AppDestinations.registerInApp, '/auth/register?source=inApp');
  });
}
