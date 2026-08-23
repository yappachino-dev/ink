import 'package:flutter/material.dart';

/// Semantic color tokens for the Ink design system.
///
/// Widgets must consume these roles (or Material's [ColorScheme] roles) —
/// never raw [Colors.black]/[Colors.white] and never ad-hoc alpha math on
/// scheme colors. Each theme palette provides a dark-first token set; the
/// light variant is a sibling, not an inversion.
class InkColors extends ThemeExtension<InkColors> {
  const InkColors({
    required this.scaffold,
    required this.surface,
    required this.container,
    required this.onSurface,
    required this.onSurfaceMuted,
    required this.outline,
    required this.scrim,
    required this.highlight,
    required this.shadow,
  });

  /// Page-level canvas behind everything.
  final Color scaffold;

  /// Raised surfaces: cards, sheets, bars.
  final Color surface;

  /// Nested containers: inputs, list tiles inside cards, wells.
  final Color container;

  /// Primary text/icon color on [surface].
  final Color onSurface;

  /// Secondary text/icon color on [surface].
  final Color onSurfaceMuted;

  /// Hairline borders and dividers.
  final Color outline;

  /// Modal barriers, drawer scrims — always a black-derived wash whose alpha
  /// is stronger in dark mode.
  final Color scrim;

  /// Primary-tinted selection/active wash to layer over [surface].
  final Color highlight;

  /// Tinted shadow color for elevation.
  final Color shadow;

  @override
  ThemeExtension<InkColors> copyWith({
    Color? scaffold,
    Color? surface,
    Color? container,
    Color? onSurface,
    Color? onSurfaceMuted,
    Color? outline,
    Color? scrim,
    Color? highlight,
    Color? shadow,
  }) {
    return InkColors(
      scaffold: scaffold ?? this.scaffold,
      surface: surface ?? this.surface,
      container: container ?? this.container,
      onSurface: onSurface ?? this.onSurface,
      onSurfaceMuted: onSurfaceMuted ?? this.onSurfaceMuted,
      outline: outline ?? this.outline,
      scrim: scrim ?? this.scrim,
      highlight: highlight ?? this.highlight,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  ThemeExtension<InkColors> lerp(
    covariant ThemeExtension<InkColors>? other,
    double t,
  ) {
    if (other is! InkColors) return this;

    return InkColors(
      scaffold: Color.lerp(scaffold, other.scaffold, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      container: Color.lerp(container, other.container, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      onSurfaceMuted: Color.lerp(onSurfaceMuted, other.onSurfaceMuted, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
      highlight: Color.lerp(highlight, other.highlight, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}
