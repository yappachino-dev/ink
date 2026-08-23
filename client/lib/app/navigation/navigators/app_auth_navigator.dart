import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/app/navigation/app_router.dart';
import 'package:ink/features/auth/presentation/navigation/auth_navigator.dart';
import 'package:ink/features/notes/presentation/navigation/notes_routes.dart';
import 'package:ink/features/vault/presentation/navigation/vault_unlock_routes.dart';
import 'package:ink/features/vault/presentation/notifiers/vault_notifier.dart';

class AppAuthNavigator implements AuthNavigator {
  const AppAuthNavigator(this.ref);

  final Ref ref;

  @override
  void onOnboardingLoginCompleted() {
    ref.read(appRouterProvider).go(const UnlockVaultRoute().location);
  }

  @override
  void onAuthCompleted() {
    unawaited(ref.read(vaultProvider.notifier).forcePushKeys());
    ref.read(appRouterProvider).go(const NotesRoute().location);
  }
}
