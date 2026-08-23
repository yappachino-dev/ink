import 'package:flutter/material.dart';
import 'package:ink/core/presentation/app_sizes.dart' as sizes;
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/features/notes/presentation/widgets/bottom_nav.dart';
import 'package:ink/features/profile/presentation/widgets/settings_card.dart';
import 'package:ink/features/profile/presentation/widgets/settings_tile.dart';
import 'package:ink/features/profile/presentation/widgets/tile_divider.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:ink/core/presentation/theme/tokens.dart';

class PersonalizationScreen extends StatelessWidget {
  const PersonalizationScreen({super.key});

  Future<void> _showDeleteConfirmDialog(BuildContext context) async {
    final textTheme = Theme.of(context).textTheme;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: context.ink.scrim,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.lgRadius,
          ),
          backgroundColor: context.ink.surface,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.t.profile.account.deleteConfirm,
                  textAlign: TextAlign.center,
                  style: textTheme.titleLarge,
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        style: FilledButton.styleFrom(
                          backgroundColor: context.colorScheme.primary,
                          foregroundColor: context.colorScheme.surface,
                          minimumSize: const Size(double.infinity, 46),
                          shape: RoundedRectangleBorder(
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

                    const SizedBox(width: 12),

                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.colorScheme.error,
                          side: BorderSide(
                            color: context.colorScheme.error,
                          ),
                          minimumSize: const Size(double.infinity, 46),
                          shape: RoundedRectangleBorder(
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

    if (confirmed == true && context.mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.ink.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 12,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: Icon(
                        Icons.chevron_left,
                        size: sizes.iconXLarge,
                        color: context.colorScheme.onSurface,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),

                  Text(
                    context.t.profile.settings.personalization,
                    style: context.textTheme.titleLarge,
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  SettingsCard(
                    children: [
                      SettingsTile(
                        icon: Icons.lock_outline,
                        title: context.t.profile.account.delete,
                        subtitle: context.t.profile.account.deleteSubtitle,
                        onTap: () => _showDeleteConfirmDialog(context),
                        showArrow: false,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  SettingsCard(
                    children: [
                      SettingsTile(
                        title: context.t.profile.personal.changeName,
                        onTap: () {},
                      ),

                      const TileDivider(),

                      SettingsTile(
                        title: context.t.profile.personal.changePassword,
                        onTap: () {},
                      ),

                      const TileDivider(),

                      SettingsTile(
                        title: context.t.profile.personal.changeEncryption,
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNav(),
    );
  }
}
