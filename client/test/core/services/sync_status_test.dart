import 'package:flutter_test/flutter_test.dart';
import 'package:ink/core/domain/sync_status.dart';
import 'package:ink/core/services/sync/sync_indexes.dart';

void main() {
  test('syncModifiedIndex matches the SyncStatus.modified ordinal', () {
    // Drift table defaults need a const int, so the ordinal is hardcoded.
    // Reordering the enum would silently corrupt every stored syncStatus —
    // this assertion makes such a change fail loudly instead.
    expect(syncModifiedIndex, SyncStatus.modified.index);
  });

  test('pending-push queue covers modified and deleted only', () {
    expect(
      syncPendingPushIndexes,
      unorderedEquals([SyncStatus.modified.index, SyncStatus.deleted.index]),
    );
    expect(syncPendingPushIndexes, isNot(contains(SyncStatus.synced.index)));
    expect(
      syncPendingPushIndexes,
      isNot(contains(SyncStatus.conflicted.index)),
    );
  });
}
