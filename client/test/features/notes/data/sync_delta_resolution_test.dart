import 'package:flutter_test/flutter_test.dart';
import 'package:ink/features/notes/data/sync_delta_resolution.dart';

void main() {
  group('resolveSyncDelta', () {
    test('missing locally + live delta => upsert', () {
      expect(
        resolveSyncDelta(
          existsLocally: false,
          locallyModified: false,
          lastSyncedVersion: 0,
          incomingVersion: 1,
          incomingDeleted: false,
        ),
        SyncDeltaResolution.upsert,
      );
    });

    test('missing locally + tombstone => skip', () {
      expect(
        resolveSyncDelta(
          existsLocally: false,
          locallyModified: false,
          lastSyncedVersion: 0,
          incomingVersion: 1,
          incomingDeleted: true,
        ),
        SyncDeltaResolution.skip,
      );
    });

    test('stale live delta => skip', () {
      expect(
        resolveSyncDelta(
          existsLocally: true,
          locallyModified: false,
          lastSyncedVersion: 3,
          incomingVersion: 2,
          incomingDeleted: false,
        ),
        SyncDeltaResolution.skip,
      );
    });

    test('equal-version live delta => skip', () {
      expect(
        resolveSyncDelta(
          existsLocally: true,
          locallyModified: false,
          lastSyncedVersion: 3,
          incomingVersion: 3,
          incomingDeleted: false,
        ),
        SyncDeltaResolution.skip,
      );
    });

    test('newer live delta + clean local => upsert', () {
      expect(
        resolveSyncDelta(
          existsLocally: true,
          locallyModified: false,
          lastSyncedVersion: 3,
          incomingVersion: 4,
          incomingDeleted: false,
        ),
        SyncDeltaResolution.upsert,
      );
    });

    test('newer tombstone + clean local => deleteLocal', () {
      expect(
        resolveSyncDelta(
          existsLocally: true,
          locallyModified: false,
          lastSyncedVersion: 3,
          incomingVersion: 4,
          incomingDeleted: true,
        ),
        SyncDeltaResolution.deleteLocal,
      );
    });

    test('equal-version tombstone + clean local => deleteLocal', () {
      // Guards against zombie rows when a delete arrives at the same version
      // as the last synced state.
      expect(
        resolveSyncDelta(
          existsLocally: true,
          locallyModified: false,
          lastSyncedVersion: 3,
          incomingVersion: 3,
          incomingDeleted: true,
        ),
        SyncDeltaResolution.deleteLocal,
      );
    });

    test('older tombstone + clean local => skip', () {
      expect(
        resolveSyncDelta(
          existsLocally: true,
          locallyModified: false,
          lastSyncedVersion: 3,
          incomingVersion: 2,
          incomingDeleted: true,
        ),
        SyncDeltaResolution.skip,
      );
    });

    test('locally modified + newer live delta => conflict', () {
      expect(
        resolveSyncDelta(
          existsLocally: true,
          locallyModified: true,
          lastSyncedVersion: 3,
          incomingVersion: 4,
          incomingDeleted: false,
        ),
        SyncDeltaResolution.conflict,
      );
    });

    test('locally modified + newer tombstone => conflict', () {
      expect(
        resolveSyncDelta(
          existsLocally: true,
          locallyModified: true,
          lastSyncedVersion: 3,
          incomingVersion: 4,
          incomingDeleted: true,
        ),
        SyncDeltaResolution.conflict,
      );
    });

    test('locally modified + equal-version tombstone => conflict', () {
      expect(
        resolveSyncDelta(
          existsLocally: true,
          locallyModified: true,
          lastSyncedVersion: 3,
          incomingVersion: 3,
          incomingDeleted: true,
        ),
        SyncDeltaResolution.conflict,
      );
    });

    test('locally modified + stale delta => skip', () {
      expect(
        resolveSyncDelta(
          existsLocally: true,
          locallyModified: true,
          lastSyncedVersion: 3,
          incomingVersion: 3,
          incomingDeleted: false,
        ),
        SyncDeltaResolution.skip,
      );
    });
  });
}
