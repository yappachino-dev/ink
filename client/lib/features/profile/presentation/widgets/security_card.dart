import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/config/user_config.dart';
import 'package:ink/core/presentation/providers/status_providers.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/theme/tokens.dart';
import 'package:ink/core/presentation/trust.dart';
import 'package:ink/features/profile/presentation/widgets/settings_card.dart';
import 'package:ink/features/profile/presentation/widgets/settings_tile.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';

/// What actually protects the notes, stated where a user goes to check (§7.4).
///
/// None of this is new functionality. It is existing state, already tracked in
/// the domain layer, that was never rendered anywhere. The encryption property
/// is stated as the verifiable thing it is - encrypted on this device, and the
/// server holds only ciphertext - rather than as a promise of privacy.
///
/// Trust is resolved from the plan gate and coarse sync activity. The notes
/// list resolves the same vocabulary more finely, because it can see each
/// note's own sync status; the profile deliberately does not claim a per-note
/// answer it cannot compute.
class SecurityCard extends ConsumerWidget {
  const SecurityCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final localOnly = ref.watch(userPreferencesProvider).localOnly;

    return SettingsCard(
      children: [
        SettingsTile(
          icon: Icons.lock_outline,
          title: t.profile.security.encryption,
          // No tappable behaviour: this is a statement, not a setting. A row
          // that looks tappable and is not is the exact defect this screen was
          // rebuilt to remove, so it has no arrow.
          onTap: () {},
          showArrow: false,
          subtitle: t.welcome.thesis,
        ),

        const _SecurityDivider(),

        SettingsTile(
          icon: _trust(localOnly, ref).icon,
          title: t.profile.security.sync,
          onTap: () {},
          showArrow: false,
          subtitle: _trust(localOnly, ref).message(t),
          subtitleColor: _trust(localOnly, ref).color(context),
        ),
      ],
    );
  }

  Trust _trust(bool localOnly, WidgetRef ref) {
    if (localOnly) return Trust.onDeviceOnly;

    return switch (ref.watch(syncActivityProvider)) {
      SyncActivity.syncing => Trust.syncing,
      SyncActivity.failed => Trust.failed,
      SyncActivity.idle => Trust.synced,
    };
  }
}

class _SecurityDivider extends StatelessWidget {
  const _SecurityDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: AppSpacing.lg,
      color: context.theme.dividerColor,
    );
  }
}
