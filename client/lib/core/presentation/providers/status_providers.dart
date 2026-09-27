import 'package:ink/core/infrastructure/network/network_state_provider.dart';
import 'package:ink/core/services/sync/sync_orchestrator.dart';
import 'package:ink/core/services/sync/sync_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'status_providers.g.dart';

/// Whether the device currently has no usable connection.
///
/// Presentation layers may not import `core/infrastructure` directly, so the
/// connectivity stream is adapted here rather than watched from a widget.
@Riverpod(keepAlive: true)
bool isOffline(Ref ref) => !ref.watch(networkStateProvider).isConnected;

/// Coarse sync activity, decoupled from the orchestrator's own state type.
enum SyncActivity { idle, syncing, failed }

@Riverpod(keepAlive: true)
SyncActivity syncActivity(Ref ref) {
  return switch (ref.watch(syncOrchestratorProvider)) {
    SyncSyncing() => SyncActivity.syncing,
    SyncError() => SyncActivity.failed,
    _ => SyncActivity.idle,
  };
}
