import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ink/app/navigation/widgets/app_bottom_nav.dart';
import 'package:ink/core/presentation/extensions/app_snack_bar_extension.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/features/vault/domain/failures/vault_failure.dart';
import 'package:ink/features/vault/domain/vault_state.dart';
import 'package:ink/features/vault/presentation/extensions/vault_failure_ui_extension.dart';
import 'package:ink/features/vault/presentation/notifiers/vault_notifier.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';

/// Hosts the navigation branches and owns the single navigation bar (F-10).
///
/// Each branch keeps its own [Navigator] inside an [IndexedStack], so leaving a
/// tab and coming back restores its scroll position, its open sheets and its
/// local state. Previously every tab switch was a `context.go()` against a flat
/// route list, which rebuilt the screen from scratch each time.
///
/// Switching tabs no longer touches any branch's state. It used to clear the
/// Notes lens when entering Calendar, because both screens read one shared
/// notebook selection and only Notes understood the `Today` pseudo-notebook.
/// Calendar is a date index now and reads no lens, so the reset has no
/// reason to exist.
class AppShell extends ConsumerWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // A rejected vault push leaves this device's unlock key unsynced for good.
    // There is no screen that owns that failure - the push runs from the auth
    // navigator and from unlock, both without a BuildContext - so it is
    // reported here, the one persistent frame in the app.
    ref.listen(vaultProvider, (previous, next) {
      if (next case VaultError(:final failure)
          when failure is VaultKeyConflict) {
        context.showSnackbarError(failure.message(context.t));
      }
    });

    return Scaffold(
      backgroundColor: context.ink.surface,
      body: navigationShell,
      bottomNavigationBar: AppBottomNav(
        currentIndex: navigationShell.currentIndex,
        onDestinationSelected: _select,
      ),
    );
  }

  void _select(int index) {
    navigationShell.goBranch(
      index,
      // Tapping the active tab returns it to its root, which is what a tab is
      // expected to do; every other switch preserves the branch's state.
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
