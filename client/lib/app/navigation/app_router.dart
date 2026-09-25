import 'package:go_router/go_router.dart';
import 'package:ink/app/presentation/app_routes.dart';
import 'package:ink/features/auth/presentation/navigation/auth_routes.dart';
import 'package:ink/features/notes/presentation/navigation/notes_routes.dart';
import 'package:ink/features/profile/presentation/navigation/profile_routes.dart';
import 'package:ink/features/vault/domain/vault_state.dart';
import 'package:ink/features/vault/presentation/navigation/vault_setup_routes.dart';
import 'package:ink/features/vault/presentation/navigation/vault_unlock_routes.dart';
import 'package:ink/features/vault/presentation/notifiers/vault_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final router = GoRouter(
    initialLocation: const SplashRoute().location,
    routes: [
      $splashRoute,
      $welcomeRoute,
      $authRoute,
      $setupVaultRoute,
      $unlockVaultRoute,
      $notesRoute,
      $profileRoute,
    ],
    redirect: (context, state) {
      final vaultState = ref.read(vaultProvider);

      final location = state.matchedLocation;

      final isGoingToAuth = location.startsWith('/auth');
      final isGoingToSetup = location.startsWith('/setup');
      final isGoingToUnlock = location.startsWith('/unlock');
      final isGoingToWelcome = location.startsWith('/welcome');

      switch (vaultState) {
        case VaultInitializing():
          return location == '/splash' ? null : '/splash';
        case VaultSessionLoadFailed():
          // Stay on splash until a retry succeeds. Falling through here would
          // treat a failed token read as "logged out" and discard a session
          // that may still be perfectly valid.
          return location == '/splash' ? null : '/splash';
        case VaultNotInitialized():
          if (isGoingToSetup || isGoingToWelcome || isGoingToAuth) return null;
          return const WelcomeRoute().location;
        case VaultLocked():
          if (isGoingToUnlock) return null;
          return const UnlockVaultRoute().location;
        case VaultUnlocked():
          if (isGoingToSetup || isGoingToUnlock || isGoingToWelcome) {
            return const NotesRoute().location;
          }
        case VaultError():
          return null;
        case VaultFatal():
          return const FatalRoute().location;
      }

      return null;
    },
  );

  ref.listen(vaultProvider, (previous, next) => router.refresh());

  return router;
}
