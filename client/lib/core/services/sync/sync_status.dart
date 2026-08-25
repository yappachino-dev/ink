enum SyncStatus { synced, modified, conflicted, deleted }

const syncModifiedIndex = 1;

/// Index values of the statuses that indicate a row has local changes not yet
/// pushed to the server. Used by DAO pending-queues.
final syncPendingPushIndexes = <int>[
  SyncStatus.modified.index,
  SyncStatus.deleted.index,
];
