import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/config/user_config.dart';
import 'package:ink/core/domain/sync_status.dart';
import 'package:ink/core/presentation/app_sizes.dart' as sizes;
import 'package:ink/core/presentation/providers/status_providers.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/theme/tokens.dart';
import 'package:ink/features/notes/presentation/notifiers/notes_notifier.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';

/// A quiet, always-present statement of where a note actually lives.
///
/// Gate-aware from the start: a free user sees "Encrypted on this device" and
/// never learns that syncing exists, which is the point. Bolting a lock icon
/// onto one message later would have meant reworking the whole copy structure.
class SyncTrustIndicator extends ConsumerWidget {
  const SyncTrustIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localOnly = ref.watch(userPreferencesProvider).localOnly;
    final trust = localOnly
        ? Trust.onDeviceOnly
        : _remoteTrust(ref);

    return Tooltip(
      // Long-press is undiscoverable on a touch screen, and a status badge in
      // an AppBar has no competing gesture to protect.
      triggerMode: TooltipTriggerMode.tap,
      message: trust.message(context.t),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              trust.icon,
              size: sizes.iconSmall,
              color: trust.color(context),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              trust.label(context.t),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: trust.color(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Trust _remoteTrust(WidgetRef ref) {
    final activity = ref.watch(syncActivityProvider);
    final notes = ref.watch(notesProvider).value ?? const {};

    if (activity == SyncActivity.syncing) return Trust.syncing;
    if (activity == SyncActivity.failed) return Trust.failed;
    if (notes.values.any((note) => note.syncStatus == SyncStatus.conflicted)) {
      return Trust.conflicted;
    }
    if (notes.values.any((note) => note.syncStatus == SyncStatus.modified)) {
      return Trust.queued;
    }
    // A Pro vault with nothing in it is in sync; there is nothing pending. The
    // on-device message is the free-tier branch only, and must never reach a
    // paying user as an upgrade prompt.
    return Trust.synced;
  }
}

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
