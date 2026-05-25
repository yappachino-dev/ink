import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'vault_navigator.g.dart';

abstract interface class VaultNavigator {
  void onAuthSelected();
}

@Riverpod(keepAlive: true)
VaultNavigator vaultNavigator(Ref ref) =>
    throw UnimplementedError('vaultNavigator must be overridden in main');
