import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ink/core/presentation/theme/custom_colors.dart';

abstract final class AppTheme {
  static const _colorsLight = FlexSchemeColor(
    primary: Color(0xFF8BA88E),
    primaryContainer: Color(0xFFE8EEE9),
    secondary: Color(0xFFA1C5A5),
    secondaryContainer: Color(0xFFD9E8DB),
    tertiary: Color(0xFFB1CEB4),
    tertiaryContainer: Color(0xFFB1CEB4),
    error: Color(0xFFBA1A1A),
    errorContainer: Color(0xFFFFDAD6),
  );

  // ignoring currently since using _colorsLight.toDark() during dev
  // ignore: unused_field
  static const _colorsDark = FlexSchemeColor(
    primary: Color(0xFF8BA88E),
    primaryContainer: Color(0xFF3D4B3F),
    primaryLightRef: Color(0xFFA1C5A5), // The color of light mode primary
    secondary: Color(0xFFADCEAF),
    secondaryContainer: Color(0xFF687C69),
    secondaryLightRef: Color(0xFFA1C5A5), // The color of light mode secondary
    tertiary: Color(0xFFBDD7BF),
    tertiaryContainer: Color(0xFF577C5A),
    tertiaryLightRef: Color(0xFFB1CEB4), // The color of light mode tertiary
    error: Color(0xFFFFB4AB),
    errorContainer: Color(0xFF93000A),
  );

  static ThemeData get lightBase => FlexThemeData.light(
    colors: _colorsLight,
    textTheme: textTheme,
    usedColors: 1,
    useMaterial3ErrorColors: true,
    subThemesData: const FlexSubThemesData(
      interactionEffects: true,
      tintedDisabledControls: true,
      useM2StyleDividerInM3: true,
      inputDecoratorIsFilled: true,
      inputDecoratorBorderType: FlexInputBorderType.outline,
      alignedDropdown: true,
      navigationRailUseIndicator: true,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
  );

  static ThemeData get darkBase => FlexThemeData.dark(
    colors: _colorsLight.toDark(),
    textTheme: textTheme,
    usedColors: 1,
    useMaterial3ErrorColors: true,
    subThemesData: const FlexSubThemesData(
      interactionEffects: true,
      tintedDisabledControls: true,
      blendOnColors: true,
      useM2StyleDividerInM3: true,
      inputDecoratorIsFilled: true,
      inputDecoratorBorderType: FlexInputBorderType.outline,
      alignedDropdown: true,
      navigationRailUseIndicator: true,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
  );

  static ThemeData get light => lightBase.copyWith(
    extensions: [
      CustomColors(
        background: lightBase.colorScheme.surfaceContainer,
        onBackground: lightBase.colorScheme.surface,
        containerColor: lightBase.colorScheme.surface,
      ),
    ],
  );

  static ThemeData get dark => darkBase.copyWith(
    extensions: [
      CustomColors(
        background: darkBase.colorScheme.surfaceContainer,
        onBackground: darkBase.colorScheme.surfaceContainerHigh,
        containerColor: darkBase.colorScheme.surfaceContainerHigh,
      ),
    ],
  );

  static TextTheme get textTheme => GoogleFonts.interTextTheme();
}
