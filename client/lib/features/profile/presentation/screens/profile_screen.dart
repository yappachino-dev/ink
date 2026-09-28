import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/presentation/extensions/bottom_sheet_extension.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/theme/tokens.dart';
import 'package:ink/features/auth/domain/auth_providers.dart';
import 'package:ink/features/profile/presentation/navigation/profile_routes.dart';
import 'package:ink/features/profile/presentation/widgets/options/appearance_sheet.dart';
import 'package:ink/features/profile/presentation/widgets/options/timezone_sheet.dart';
import 'package:ink/features/profile/presentation/widgets/options/widgets_sheet.dart';
import 'package:ink/features/profile/presentation/widgets/security_card.dart';
import 'package:ink/features/profile/presentation/widgets/settings_card.dart';
import 'package:ink/features/profile/presentation/widgets/settings_tile.dart';
import 'package:ink/features/profile/presentation/widgets/tile_divider.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';

/// Settings, and nothing else.
///
/// This screen used to open on an avatar labelled "Name" and "Email" - literal
/// translation placeholders, not data - above a "Create account" row whose
/// `onTap` did nothing, with a second copy of the same screen behind a
/// `_hasAccount` flag that was hardcoded false. Cutting the unwired parts reads
/// as more finished than leaving broken stubs behind (D-4, D-5, §7.4).
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Future<void> _openAppearance() =>
      context.showAppBottomSheetLayout<void>(child: const AppearanceSheet());

  Future<void> _openTimezone() =>
      context.showAppBottomSheetLayout<void>(child: const TimezoneSheet());

  Future<void> _openWidgets() =>
      context.showAppBottomSheetLayout<void>(child: const WidgetsSheet());

  @override
  Widget build(BuildContext context) {
    final t = context.t;

    return Scaffold(
      backgroundColor: context.ink.surface,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xxl,
          ),
          children: [
            const SecurityCard(),

            const SizedBox(height: AppSpacing.xl),

            SettingsCard(
              children: [
                SettingsTile(
                  icon: Icons.tune_outlined,
                  title: t.profile.settings.personalization,
                  onTap: () => const PersonalizationRoute().push<void>(context),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            SettingsCard(
              children: [
                SettingsTile(
                  icon: Icons.dark_mode_outlined,
                  title: t.profile.settings.appearance.title,
                  onTap: _openAppearance,
                ),

                const TileDivider(),

                SettingsTile(
                  icon: Icons.access_time_outlined,
                  title: t.profile.settings.dateTime,
                  onTap: _openTimezone,
                ),

                const TileDivider(),

                SettingsTile(
                  icon: Icons.widgets_outlined,
                  title: t.profile.settings.widgets,
                  onTap: _openWidgets,
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            SettingsCard(
              children: [
                _LogoutTile(
                  onTap: () =>
                      unawaited(ref.read(authServiceProvider).logout()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoutTile extends StatelessWidget {
  const _LogoutTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.lgRadius,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        child: Center(
          child: Text(
            context.t.profile.personal.logout,
            style: context.textTheme.titleMedium?.copyWith(
              color: context.colorScheme.error,
            ),
          ),
        ),
      ),
    );
  }
}
