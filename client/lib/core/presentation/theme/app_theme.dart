import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ink/core/presentation/theme/ink_colors.dart';
import 'package:ink/core/presentation/theme/palettes.dart';

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

    return base.copyWith(
      colorScheme: accessibleScheme,
      extensions: [_tokens(accessibleScheme, brightness)],
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
      onPrimary: _readableOn(primary),
      onSecondary: _readableOn(scheme.secondary),
      onTertiary: _readableOn(scheme.tertiary),
      onError: _readableOn(scheme.error),
    );
  }

  static Color _readableOn(Color background) {
    final onBlack = _contrastRatio(Colors.black, background);
    final onWhite = _contrastRatio(Colors.white, background);
    return onBlack >= onWhite ? Colors.black : Colors.white;
  }

  static double _contrastRatio(Color foreground, Color background) {
    final foregroundLuminance = foreground.computeLuminance();
    final backgroundLuminance = background.computeLuminance();
    final lighter = foregroundLuminance > backgroundLuminance
        ? foregroundLuminance
        : backgroundLuminance;
    final darker = foregroundLuminance > backgroundLuminance
        ? backgroundLuminance
        : foregroundLuminance;
    return (lighter + 0.05) / (darker + 0.05);
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
      container: isDark ? cs.surfaceContainerHigh : cs.surfaceContainerLow,
      onSurface: cs.onSurface,
      onSurfaceMuted: cs.onSurfaceVariant,
      outline: cs.outlineVariant,
      scrim: Colors.black.withValues(alpha: isDark ? 0.6 : 0.45),
      highlight: cs.primary.withValues(alpha: isDark ? 0.24 : 0.12),
      shadow: (isDark ? Colors.black : cs.shadow).withValues(
        alpha: isDark ? 0.4 : 0.16,
      ),
    );
  }

  static TextTheme get textTheme => GoogleFonts.interTextTheme();
}
