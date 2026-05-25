import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/app/navigation/app_router.dart';
import 'package:ink/features/auth/presentation/navigation/auth_routes.dart';
import 'package:ink/features/vault/presentation/navigation/vault_navigator.dart';

class AppVaultNavigator implements VaultNavigator {
  const AppVaultNavigator(this.ref);

  final Ref ref;

  @override
  void onAuthSelected() {
    ref.read(appRouterProvider).go(const AuthRoute().location);
  }
}
