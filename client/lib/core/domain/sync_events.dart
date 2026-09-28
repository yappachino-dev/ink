import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SyncEvent { completed }

/// Domain-facing command port for starting synchronization.
abstract interface class SyncController {
  Future<void> performSync();
}

/// Domain-facing stream of successful synchronization events.
final syncEventsProvider = StreamProvider<SyncEvent>(
  (ref) =>
      throw StateError('syncEventsProvider must be overridden at the app root'),
);

/// Domain-facing synchronization command dependency.
final syncControllerProvider = Provider<SyncController>(
  (ref) => throw StateError(
    'syncControllerProvider must be overridden at the app root',
  ),
);
