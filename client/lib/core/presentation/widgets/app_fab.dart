import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/theme/tokens.dart';
import 'package:material_ui/material_ui.dart';

/// The app's single floating action button.
///
/// Notes and Calendar both add a note, and both had built their own button.
/// They drifted in three ways at once: the inset from the screen edge (one was
/// `Positioned` by hand, the other used the Scaffold's default margin), the
/// elevation, and the colours. The inset is the one users can see - the button
/// visibly jumped when switching tabs, because one screen put it 20px from the
/// edge and the other 16px.
///
/// Both now come from here, and both place it with [AppFabLocation], so the
/// position is [AppSpacing.fabInset] in one place and a change to that constant
/// moves every screen's button together.
///
/// The Scaffold's own slot is used rather than a hand-placed `Positioned`,
/// because the shell's navigation bar belongs to an outer Scaffold: the inner
/// Scaffold ends at the top of that bar, so the slot lands in the same place a
/// hand-placed `Positioned(bottom: ...)` would - and additionally keeps the
/// button clear of the keyboard, which a manual offset never did.
class AppFab extends StatelessWidget {
  const AppFab({required this.onPressed, super.key});

  /// Null disables the button. A disabled FAB is not hit-testable, so a caller
  /// that hides one behind an overlay cannot have it swallow the overlay's
  /// taps.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: context.colorScheme.primary,
      foregroundColor: context.colorScheme.surface,
      elevation: 0,
      shape: const CircleBorder(),
      child: const Icon(Icons.add, size: AppSize.iconXLarge),
    );
  }
}

/// Places [AppFab] one inset from the trailing and bottom edges.
///
/// The built-in end-float location hard-codes its own margin, so using it would
/// leave the position un-tokened: changing the app's edge spacing would skip
/// the button. This reads `AppSpacing.fabInset` like everything else.
class AppFabLocation extends StandardFabLocation
    with FabEndOffsetX, FabFloatOffsetY {
  const AppFabLocation();

  @override
  String toString() => 'AppFabLocation';

  @override
  double getOffsetX(
    ScaffoldPrelayoutGeometry scaffoldGeometry,
    double adjustment,
  ) {
    // The built-in version of this, with kFloatingActionButtonMargin replaced.
    // Direction-aware in the same way, so it mirrors correctly in RTL.
    return switch (scaffoldGeometry.textDirection) {
      TextDirection.rtl =>
        AppSpacing.fabInset + scaffoldGeometry.minInsets.left - adjustment,
      TextDirection.ltr =>
        scaffoldGeometry.scaffoldSize.width -
            AppSpacing.fabInset -
            scaffoldGeometry.minInsets.right -
            scaffoldGeometry.floatingActionButtonSize.width +
            adjustment,
    };
  }

  @override
  double getOffsetY(
    ScaffoldPrelayoutGeometry scaffoldGeometry,
    double adjustment,
  ) {
    // Anchored to contentBottom, not the scaffold height: the navigation bar
    // belongs to an outer Scaffold, so this is the top of that bar and the
    // button sits in the same place a hand-placed bottom inset would put it.
    return scaffoldGeometry.contentBottom -
        scaffoldGeometry.floatingActionButtonSize.height -
        AppSpacing.fabInset;
  }
}
