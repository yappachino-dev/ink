/// Resolution decision for a single incoming sync delta.
enum SyncDeltaResolution {
  /// Nothing to do: the local row is already up to date, or the delta
  /// describes a deletion of an entity that does not exist locally.
  skip,

  /// Write the incoming state (create or overwrite the local row).
  upsert,

  /// Remove the local row because it was deleted on the server and has no
  /// unsynced local changes.
  deleteLocal,

  /// Both sides changed concurrently: keep the local row (marked as
  /// conflicted) and store the incoming state for later resolution.
  conflict,
}

/// Pure decision function shared by every versioned sync entity.
///
/// Semantics:
/// - An entity missing locally is created unless the delta is a tombstone.
/// - A tombstone counts as a change when its version is *equal or above* the
///   last synced version — equality is allowed so a late-arriving delete can
///   never leave a zombie row behind.
/// - Any other delta only matters if its version is strictly above the last
///   synced version (the server never re-sends already-applied deltas).
/// - Concurrent changes (locally modified + server changed) always resolve to
///   [SyncDeltaResolution.conflict]; data is never silently dropped.
SyncDeltaResolution resolveSyncDelta({
  required bool existsLocally,
  required bool locallyModified,
  required int lastSyncedVersion,
  required int incomingVersion,
  required bool incomingDeleted,
}) {
  if (!existsLocally) {
    return incomingDeleted
        ? SyncDeltaResolution.skip
        : SyncDeltaResolution.upsert;
  }

  final remoteChanged = incomingDeleted
      ? incomingVersion >= lastSyncedVersion
      : incomingVersion > lastSyncedVersion;

  if (!remoteChanged) return SyncDeltaResolution.skip;

  if (locallyModified) return SyncDeltaResolution.conflict;

  return incomingDeleted
      ? SyncDeltaResolution.deleteLocal
      : SyncDeltaResolution.upsert;
}
