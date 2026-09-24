import 'package:ink/core/domain/sync_status.dart';

/// Ordinal used by Drift table defaults.
const syncModifiedIndex = 1;

/// Index values of statuses that indicate a row has local changes not yet
/// pushed to the server. Used by DAO pending queues.
final syncPendingPushIndexes = <int>[
  SyncStatus.modified.index,
  SyncStatus.deleted.index,
];
