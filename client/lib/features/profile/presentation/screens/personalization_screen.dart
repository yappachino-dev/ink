import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ink/core/presentation/extensions/app_snack_bar_extension.dart';
import 'package:ink/core/presentation/navigation/app_destinations.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/theme/tokens.dart';
import 'package:ink/core/presentation/widgets/back_app_bar.dart';
import 'package:ink/features/profile/presentation/widgets/settings_card.dart';
import 'package:ink/features/profile/presentation/widgets/settings_tile.dart';
import 'package:ink/features/profile/presentation/widgets/tile_divider.dart';
import 'package:ink/features/vault/domain/vault_providers.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';

class PersonalizationScreen extends ConsumerWidget {
  const PersonalizationScreen({super.key});

  Future<void> _showDeleteConfirmDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final textTheme = Theme.of(context).textTheme;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: context.ink.scrim,
      builder: (ctx) {
        return Dialog(
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgRadius),
          backgroundColor: context.ink.surface,
          child: Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.xxl,
              right: AppSpacing.xxl,
              top: AppSpacing.xxl,
              bottom: AppSpacing.xl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.t.profile.account.deleteConfirm,
                  textAlign: TextAlign.center,
                  style: textTheme.titleLarge,
                ),

                const SizedBox(height: AppSpacing.md),

                // Spelled out because the action is irreversible and
                // device-scoped: it drops the vault keys, so anything not
                // already synced becomes unrecoverable rather than merely
                // deleted.
                Text(
                  context.t.profile.account.deleteBody,
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall,
                ),

                const SizedBox(height: AppSpacing.xxl),

                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        style: FilledButton.styleFrom(
                          backgroundColor: context.colorScheme.primary,
                          foregroundColor: context.colorScheme.surface,
                          minimumSize: const Size(double.infinity, 46),
                          shape: const RoundedRectangleBorder(
                            borderRadius: AppRadius.lgRadius,
                          ),
                        ),
                        child: Text(
                          context.t.common.cancel,
                          style: textTheme.labelMedium?.copyWith(
                            color: context.colorScheme.surface,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: AppSpacing.md),

                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.colorScheme.error,
                          side: BorderSide(color: context.colorScheme.error),
                          minimumSize: const Size(double.infinity, 46),
                          shape: const RoundedRectangleBorder(
                            borderRadius: AppRadius.lgRadius,
                          ),
                        ),
                        child: Text(
                          context.t.common.delete,
                          style: textTheme.labelMedium?.copyWith(
                            color: context.colorScheme.error,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    // `VaultRecovery.reset()` is the operation the fatal screen already uses:
    // it drops every local table including the vault keys, zeroes the sync
    // cursor, and clears both tokens. Nothing else here makes key material
    // unreadable, so hiding rows alone would leave recoverable ciphertext on
    // disk.
    if (confirmed == true && context.mounted) {
      await ref.read(vaultRecoveryProvider).reset();
      // Back to onboarding. The router redirects on `VaultNotInitialized`, but
      // a redirect only runs on navigation, and staying put would leave the
      // user on a screen whose data no longer exists.
      if (context.mounted) context.go(AppDestinations.welcome);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The shared BackAppBar rather than the hand-rolled Stack that was here:
    // the local copy had drifted, using a Material chevron where BackAppBar
    // uses the iOS-style arrow, so the same screen showed two different back
    // affordances. Still a Scaffold rather than SpacedScaffold - the content is
    // a scrolling list, and SpacedScaffold wraps children in a
    // SliverFillRemaining that cannot measure a viewport.
    return Scaffold(
      backgroundColor: context.ink.surface,
      appBar: const BackAppBar(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: Text(
                context.t.profile.settings.personalization,
                style: context.textTheme.titleLarge,
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                children: [
                  SettingsCard(
                    children: [
                      SettingsTile(
                        icon: Icons.lock_outline,
                        title: context.t.profile.account.delete,
                        subtitle: context.t.profile.account.deleteSubtitle,
                        onTap: () => _showDeleteConfirmDialog(context, ref),
                        showArrow: false,
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.md),

                  SettingsCard(
                    children: [
                      // These three are routed nowhere. They stay visible and
                      // answer with an explicit "not available yet" rather than
                      // an empty tap handler, because a row that renders but
                      // swallows the tap reads as working. There is no
                      // change-name, change-password or re-key endpoint, so a
                      // stub would only trade one kind of lie for another.
                      //
                      // "Change encryption method" is not a preference either:
                      // the key encrypts notes that already exist, so it is a
                      // re-encryption operation.
                      SettingsTile(
                        title: context.t.profile.personal.changeName,
                        onTap: () => context.showSnackBarInfo(
                          context.t.common.notImplemented,
                        ),
                      ),

                      const TileDivider(),

                      SettingsTile(
                        title: context.t.profile.personal.changePassword,
                        onTap: () => context.showSnackBarInfo(
                          context.t.common.notImplemented,
                        ),
                      ),

                      const TileDivider(),

                      SettingsTile(
                        title: context.t.profile.personal.changeEncryption,
                        onTap: () => context.showSnackBarInfo(
                          context.t.common.notImplemented,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
