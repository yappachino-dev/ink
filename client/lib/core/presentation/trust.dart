import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';

/// How a note's protection currently stands, in words.
///
/// The vocabulary lives in core so that the notes surface and the profile can
/// both speak about it. Whether a sync actually succeeded is decided per
/// surface: the notes list can see every note's sync status, while the profile
/// only has the coarse activity and the plan gate.
enum Trust {
  onDeviceOnly(Icons.lock_outline, 'trust.onDevice'),
  queued(Icons.cloud_upload_outlined, 'trust.queued'),
  syncing(Icons.sync, 'trust.syncing'),
  synced(Icons.cloud_done_outlined, 'trust.synced'),
  failed(Icons.cloud_off_outlined, 'trust.failed'),
  conflicted(Icons.warning_amber_rounded, 'trust.conflicted');

  const Trust(this.icon, this.key);

  final IconData icon;
  final String key;

  String label(Translations t) => switch (this) {
    Trust.onDeviceOnly => t.trust.onDevice,
    Trust.queued => t.trust.queued,
    Trust.syncing => t.trust.syncing,
    Trust.synced => t.trust.synced,
    Trust.failed => t.trust.failed,
    Trust.conflicted => t.trust.conflicted,
  };

  String message(Translations t) => switch (this) {
    Trust.onDeviceOnly => t.trust.onDeviceMessage,
    Trust.queued => t.trust.queuedMessage,
    Trust.syncing => t.trust.syncingMessage,
    Trust.synced => t.trust.syncedMessage,
    Trust.failed => t.trust.failedMessage,
    Trust.conflicted => t.trust.conflictedMessage,
  };

  Color color(BuildContext context) => switch (this) {
    Trust.failed || Trust.conflicted => context.colorScheme.error,
    _ => context.colorScheme.onSurfaceVariant,
  };
}
