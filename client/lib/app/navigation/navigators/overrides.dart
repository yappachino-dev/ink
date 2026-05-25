import 'package:ink/app/navigation/navigators/app_auth_navigator.dart';
import 'package:ink/app/navigation/navigators/app_vault_navigator.dart';
import 'package:ink/features/auth/presentation/navigation/auth_navigator.dart';
import 'package:ink/features/vault/presentation/navigation/vault_navigator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

List<Override> overrideNavigators() {
  return [
    vaultNavigatorProvider.overrideWith(AppVaultNavigator.new),
    authNavigatorProvider.overrideWith(AppAuthNavigator.new),
  ];
}
