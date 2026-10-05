import 'dart:async';

// The register screen's "I already have an account" escape hatch.
//
// It used to `safePop()`, which returned to Profile - a screen whose only
// account entry point is "Create account", so a user with an existing account
// bounced between the two forever. Pushing instead of replacing fixed the loop
// but grew the stack on every bounce, so it replaces.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:ink/core/presentation/providers/status_providers.dart';
import 'package:ink/core/presentation/theme/app_theme.dart';
import 'package:ink/core/presentation/theme/palettes.dart';
import 'package:ink/features/auth/domain/auth_providers.dart';
import 'package:ink/features/auth/domain/auth_service.dart';
import 'package:ink/features/auth/presentation/screens/register_screen.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

class _Auth extends Mock implements AuthService {}

void main() {
  Future<void> build(WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Text('PROFILE')),
        ),
        // `AuthRoute().location` is `/auth`, so the typed route has to exist
        // for the replacement to resolve.
        GoRoute(path: '/auth', builder: (_, _) => const Text('SIGN IN')),
        GoRoute(
          path: '/auth/register',
          builder: (_, _) => const RegisterScreen(source: 'inApp'),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authServiceProvider.overrideWithValue(_Auth()),
          isOfflineProvider.overrideWithValue(false),
        ],
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

  testWidgets('the escape hatch replaces register instead of stacking it', (
    tester,
  ) async {
    await build(tester);

    // Land on the register screen the way Profile does.
    unawaited(
      GoRouter.of(tester.element(find.text('PROFILE'))).push('/auth/register'),
    );
    await tester.pumpAndSettle();
    expect(find.byType(RegisterScreen), findsOneWidget);

    // The tappable node is the "Login" label, not the caption above it.
    await tester.tap(find.text(t.auth.login.action));
    await tester.pumpAndSettle();

    // Sign-in replaced it rather than sitting on top of it, so a back
    // navigation leaves this flow entirely instead of returning to register.
    expect(find.text('SIGN IN'), findsOneWidget);
    // `skipOffstage: false` is the whole point: with a push, register is still
    // mounted underneath, just offstage, and the default finder would call
    // that absent.
    expect(find.byType(RegisterScreen, skipOffstage: false), findsNothing);
  });
}
