import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ink/core/presentation/theme/contrast.dart';
import 'package:ink/core/presentation/theme/ink_colors.dart';
import 'package:ink/core/presentation/theme/palettes.dart';
import 'package:material_ui/material_ui.dart';

/// Builds [ThemeData] for a palette in a given brightness.
///
/// Dark is the design source of truth: its tuning (blends, surface ramps,
/// token alphas) is authored first and light mode is derived as a sibling
/// using the same structure. Adding a new palette only requires appending an
/// [InkPalette] entry.
abstract final class AppTheme {
  static ThemeData dark(InkPalette palette) => _theme(palette, Brightness.dark);

  static ThemeData light(InkPalette palette) =>
      _theme(palette, Brightness.light);

  static ThemeData _theme(InkPalette palette, Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final base = isDark
        ? FlexThemeData.dark(
            colors: FlexSchemeColor.from(primary: palette.seed),
            textTheme: textTheme,
            useMaterial3ErrorColors: true,
            subThemesData: _subThemes,
            visualDensity: FlexColorScheme.comfortablePlatformDensity,
            cupertinoOverrideTheme: const CupertinoThemeData(
              applyThemeToAll: true,
            ),
          )
        : FlexThemeData.light(
            colors: FlexSchemeColor.from(primary: palette.seed),
            textTheme: textTheme,
            useMaterial3ErrorColors: true,
            subThemesData: _subThemes,
            visualDensity: FlexColorScheme.comfortablePlatformDensity,
            cupertinoOverrideTheme: const CupertinoThemeData(
              applyThemeToAll: true,
            ),
          );

    final accessibleScheme = _accessibleColorScheme(
      base.colorScheme,
      brightness,
    );

    final tokens = _tokens(accessibleScheme, brightness);

    return base.copyWith(
      colorScheme: accessibleScheme,
      // `flutter_quill` reads `Theme.of(context).canvasColor` for the editor
      // chrome and falls back to the light default, which is how a bright
      // toolbar strip ended up inside the dark editor. Theming the role fixes
      // the widget without the toolbar having to know about it.
      canvasColor: accessibleScheme.surface,
      extensions: [tokens],
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          disabledBackgroundColor: tokens.disabledBackground,
          disabledForegroundColor: tokens.disabledForeground,
        ),
      ),
    );
  }

  static ColorScheme _accessibleColorScheme(
    ColorScheme scheme,
    Brightness brightness,
  ) {
    final primary = brightness == Brightness.light
        ? HSLColor.fromColor(scheme.primary)
              .withLightness(
                HSLColor.fromColor(scheme.primary).lightness > 0.30
                    ? 0.30
                    : HSLColor.fromColor(scheme.primary).lightness,
              )
              .toColor()
        : scheme.primary;

    return scheme.copyWith(
      primary: primary,
      onPrimary: readableInkOn(primary),
      onSecondary: readableInkOn(scheme.secondary),
      onTertiary: readableInkOn(scheme.tertiary),
      onError: readableInkOn(scheme.error),
    );
  }

  static const _subThemes = FlexSubThemesData(
    interactionEffects: true,
    tintedDisabledControls: true,
    useM2StyleDividerInM3: true,
    inputDecoratorIsFilled: true,
    inputDecoratorBorderType: FlexInputBorderType.outline,
    alignedDropdown: true,
    navigationRailUseIndicator: true,
    blendOnColors: true,
  );

  /// Semantic tokens derived from the resolved scheme. Structure is identical
  /// for both brightnesses; only tone choices differ (dark-first tuning).
  static InkColors _tokens(ColorScheme cs, Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    return InkColors(
      scaffold: isDark ? cs.surface : cs.surfaceContainer,
      surface: isDark ? cs.surfaceContainer : cs.surface,
      // Editor chrome: the one surface that sits against editable content.
      // A named token rather than a reach for `colorScheme.surfaceContainer`
      // at the call site, because reaching for the raw role in one place and
      // `ink.*` in another is exactly how the toolbar and the scaffold ended
      // up disagreeing in dark only.
      //
      // It is chosen per brightness against [surface] rather than fixed,
      // because `surface` is not one raw role either: in dark it is already
      // `surfaceContainer`, so a fixed `surfaceContainer` chrome would have
      // been *identical* to the note surface in dark - an invisible tint in
      // exactly the theme where the band bug was visible. One step further out
      // in each, which also keeps the direction right: chrome is darker than
      // the page in light and lighter in dark, so it lifts off in both.
      chrome: isDark ? cs.surfaceContainerHigh : cs.surfaceContainer,
      container: isDark ? cs.surfaceContainerHigh : cs.surfaceContainerLow,
      onSurface: cs.onSurface,
      onSurfaceMuted: cs.onSurfaceVariant,
      outline: cs.outlineVariant,
      scrim: Colors.black.withValues(alpha: isDark ? 0.6 : 0.45),
      highlight: cs.primary.withValues(alpha: isDark ? 0.24 : 0.12),
      shadow: (isDark ? Colors.black : cs.shadow).withValues(
        alpha: isDark ? 0.4 : 0.16,
      ),
      // A visible recess rather than Material's near-invisible wash. The label
      // is `onSurface`, the strongest role, so a disabled action still reads as
      // an action that is merely not available yet (F-12).
      disabledBackground: isDark
          ? cs.surfaceContainerHighest
          : cs.surfaceContainerHigh,
      disabledForeground: cs.onSurface,
    );
  }

  static TextTheme get textTheme {
    final googleTextTheme = GoogleFonts.interTextTheme();

    // google_fonts currently exposes the SDK Material TextTheme, while
    // flex_color_scheme 9 uses the decoupled material_ui TextTheme. TextStyle
    // itself is shared, so copying the style slots is type-safe.
    return TextTheme(
      displayLarge: googleTextTheme.displayLarge,
      displayMedium: googleTextTheme.displayMedium,
      displaySmall: googleTextTheme.displaySmall,
      headlineLarge: googleTextTheme.headlineLarge,
      headlineMedium: googleTextTheme.headlineMedium,
      headlineSmall: googleTextTheme.headlineSmall,
      titleLarge: googleTextTheme.titleLarge,
      titleMedium: googleTextTheme.titleMedium,
      titleSmall: googleTextTheme.titleSmall,
      bodyLarge: googleTextTheme.bodyLarge,
      bodyMedium: googleTextTheme.bodyMedium,
      bodySmall: googleTextTheme.bodySmall,
      labelLarge: googleTextTheme.labelLarge,
      labelMedium: googleTextTheme.labelMedium,
      labelSmall: googleTextTheme.labelSmall,
    );
  }
}
