import 'package:ink/features/vault/data/ports/vault_local_store.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'vault_local_store_provider.g.dart';

@Riverpod(keepAlive: true)
VaultLocalStore vaultLocalStore(Ref ref) => throw StateError(
  'vaultLocalStoreProvider must be overridden at the app root',
);
