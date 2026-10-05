import 'package:ink/features/vault/domain/failures/vault_failure.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'vault_conflict_notifier.g.dart';

/// Carries a vault conflict as a one-shot report, separate from the vault
/// lifecycle state.
///
/// A refused key-slot push happens while the vault is unlocked and working, so
/// folding it into the lifecycle state would drop an unlocked device into
/// `VaultError` and leave it there. This holds the report on its own, which
/// the shell reads and clears.
@Riverpod(keepAlive: true)
class VaultConflictNotifier extends _$VaultConflictNotifier {
  @override
  VaultFailure? build() => null;

  VaultFailure? get conflict => state;

  set conflict(VaultFailure? value) => state = value;

}
