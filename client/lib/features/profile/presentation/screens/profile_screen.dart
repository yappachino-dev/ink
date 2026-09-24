import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ink/app/navigation/widgets/app_bottom_nav.dart';
import 'package:ink/core/presentation/app_sizes.dart' as sizes;
import 'package:ink/core/presentation/extensions/bottom_sheet_extension.dart';
import 'package:ink/core/presentation/navigation/app_destinations.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/theme/tokens.dart';
import 'package:ink/features/auth/domain/auth_providers.dart';
import 'package:ink/features/profile/presentation/navigation/profile_routes.dart';
import 'package:ink/features/profile/presentation/widgets/options/appearance_sheet.dart';
import 'package:ink/features/profile/presentation/widgets/options/langauge_sheet.dart';
import 'package:ink/features/profile/presentation/widgets/options/timezone_sheet.dart';
import 'package:ink/features/profile/presentation/widgets/options/widgets_sheet.dart';
import 'package:ink/features/profile/presentation/widgets/settings_card.dart';
import 'package:ink/features/profile/presentation/widgets/settings_tile.dart';
import 'package:ink/features/profile/presentation/widgets/tile_divider.dart';
import 'package:ink/i18n/strings.g.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final bool _hasAccount = false;

  Future<void> _openLanguage() async =>
      context.showAppBottomSheetLayout<void>(child: const LanguageSheet());

  Future<void> _openAppearance() async =>
      context.showAppBottomSheetLayout<void>(child: const AppearanceSheet());

  Future<void> _openTimezone() async => context.showAppBottomSheetLayout<void>(
    child: const TimezoneSheet(),
  );

  Future<void> _openWidgets() async =>
      context.showAppBottomSheetLayout<void>(child: const WidgetsSheet());

  void _onDestinationSelected(int index) {
    switch (index) {
      case 0:
        context.go(AppDestinations.notes);
      case 1:
        context.go(AppDestinations.calendar);
      case 2:
        context.go(AppDestinations.profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.ink.surface,
      body: SafeArea(
        child: _hasAccount
            ? _AccountView(
                onLanguageTap: _openLanguage,
                onAppearanceTap: _openAppearance,
                onTimezoneTap: _openTimezone,
                onWidgetsTap: _openWidgets,
              )
            : _LocalView(
                onLanguageTap: _openLanguage,
                onAppearanceTap: _openAppearance,
                onTimezoneTap: _openTimezone,
                onWidgetsTap: _openWidgets,
                onLogout: () {
                  unawaited(ref.read(authServiceProvider).logout());
                },
              ),
      ),
      bottomNavigationBar: AppBottomNav(
        onDestinationSelected: _onDestinationSelected,
      ),
    );
  }
}

class _AccountView extends StatelessWidget {
  const _AccountView({
    required this.onLanguageTap,
    required this.onAppearanceTap,
    required this.onTimezoneTap,
    required this.onWidgetsTap,
  });

  final VoidCallback onLanguageTap;
  final VoidCallback onAppearanceTap;
  final VoidCallback onTimezoneTap;
  final VoidCallback onWidgetsTap;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      children: [
        _ProfileHeader(
          name: context.t.profile.personal.name,
          email: context.t.profile.personal.email,
          onTap: () {},
        ),

        const SizedBox(height: 12),

        SettingsCard(
          children: [
            SettingsTile(
              icon: Icons.lock_outline,
              title: context.t.profile.account.create,
              subtitle: context.t.profile.account.createSubtitle,
              onTap: () {},
            ),
          ],
        ),

        const SizedBox(height: 12),

        SettingsCard(
          children: [
            SettingsTile(
              icon: Icons.language_outlined,
              title: context.t.profile.settings.language,
              onTap: onLanguageTap,
            ),

            const TileDivider(),

            SettingsTile(
              icon: Icons.dark_mode_outlined,
              title: context.t.profile.settings.appearance.title,
              onTap: onAppearanceTap,
            ),

            const TileDivider(),

            SettingsTile(
              icon: Icons.access_time_outlined,
              title: context.t.profile.settings.dateTime,
              onTap: onTimezoneTap,
            ),

            const TileDivider(),

            SettingsTile(
              icon: Icons.widgets_outlined,
              title: context.t.profile.settings.widgets,
              onTap: onWidgetsTap,
            ),
          ],
        ),
      ],
    );
  }
}

class _LocalView extends StatelessWidget {
  const _LocalView({
    required this.onLanguageTap,
    required this.onAppearanceTap,
    required this.onTimezoneTap,
    required this.onWidgetsTap,
    required this.onLogout,
  });

  final VoidCallback onLanguageTap;
  final VoidCallback onAppearanceTap;
  final VoidCallback onTimezoneTap;
  final VoidCallback onWidgetsTap;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final t = context.t;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      children: [
        _ProfileHeader(
          name: context.t.profile.personal.name,
          email: context.t.profile.personal.email,
          onTap: () => context.go(AppDestinations.authInApp),
        ),

        const SizedBox(height: 12),

        SettingsCard(
          children: [
            SettingsTile(
              icon: Icons.lock_outline,
              title: t.profile.settings.personalization,
              onTap: () => const PersonalizationRoute().push<void>(context),
            ),
          ],
        ),

        const SizedBox(height: 12),

        SettingsCard(
          children: [
            SettingsTile(
              icon: Icons.language_outlined,
              title: context.t.profile.settings.language,
              onTap: onLanguageTap,
            ),

            const TileDivider(),

            SettingsTile(
              icon: Icons.dark_mode_outlined,
              title: context.t.profile.settings.appearance.title,
              onTap: onAppearanceTap,
            ),

            const TileDivider(),

            SettingsTile(
              icon: Icons.access_time_outlined,
              title: context.t.profile.settings.dateTime,
              onTap: onTimezoneTap,
            ),

            const TileDivider(),

            SettingsTile(
              icon: Icons.widgets_outlined,
              title: context.t.profile.settings.widgets,
              onTap: onWidgetsTap,
            ),
          ],
        ),

        const SizedBox(height: 12),

        SettingsCard(
          children: [_LogoutTile(onTap: onLogout)],
        ),
      ],
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.name,
    required this.email,
    required this.onTap,
  });

  final String name;
  final String email;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: context.ink.surface,
          borderRadius: AppRadius.lgRadius,
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: context.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_outline,
                color: context.colorScheme.surface,
                size: 32,
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: context.textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(email, style: context.textTheme.bodySmall),
                ],
              ),
            ),

            Icon(
              Icons.chevron_right,
              size: sizes.iconMedium,
              color: context.theme.hintColor,
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Center(
          child: Text(
            context.t.profile.personal.logout,
            style: context.textTheme.titleMedium?.copyWith(
              color: context.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
