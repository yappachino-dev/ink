import 'package:ink/core/domain/core_failure.dart';

sealed class SyncState {
  const SyncState();
}

class SyncIdle extends SyncState {
  const SyncIdle();
}

class SyncSyncing extends SyncState {
  const SyncSyncing();
}

class SyncSuccess extends SyncState {
  const SyncSuccess();
}

class SyncError extends SyncState {
  const SyncError(this.failure);

  final CoreFailure failure;
}
