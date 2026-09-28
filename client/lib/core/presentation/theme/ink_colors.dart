import 'package:material_ui/material_ui.dart';

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
    required this.chrome,
    required this.container,
    required this.onSurface,
    required this.onSurfaceMuted,
    required this.outline,
    required this.scrim,
    required this.highlight,
    required this.shadow,
    required this.disabledBackground,
    required this.disabledForeground,
  });

  /// Fill of a control that cannot be used yet.
  ///
  /// Material's default is `onSurface` at 12% alpha, which composites to a
  /// value close to the surface itself; the label then measures 1.2:1 in light
  /// and 2.7:1 in dark against it. A control you cannot see is a control you
  /// cannot tell apart from the page.
  final Color disabledBackground;

  /// Label of a control that cannot be used yet. Meets the same 4.5:1 bar the
  /// theme contrast test enforces for every other content role.
  final Color disabledForeground;

  /// Page-level canvas behind everything.
  final Color scaffold;

  /// Raised surfaces: cards, sheets, bars.
  final Color surface;

  /// Nested containers: inputs, list tiles inside cards, wells.
  final Color container;

  /// Non-editable chrome that sits against editable content — currently the
  /// editor's bottom bar, holding the meta row and the formatting toolbar.
  ///
  /// Distinct from [surface] on purpose. The note area is the only place in the
  /// app that accepts a cursor, so the boundary between "type here" and "tap
  /// here" should be visible rather than implied by a hairline. One step of
  /// M3 container, which is *darker* than the surface in light and *lighter*
  /// in dark, so the chrome lifts off the page in both themes.
  ///
  /// Deliberately not [container]: that is the card role, and merging the two
  /// would make "card" and "chrome" the same word. Deliberately not
  /// `surfaceContainerLow` either — it is four steps off the surface in light,
  /// close enough to the near-identical greys that read as a rendering fault
  /// rather than a decision.
  final Color chrome;

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
    Color? chrome,
    Color? container,
    Color? onSurface,
    Color? onSurfaceMuted,
    Color? outline,
    Color? scrim,
    Color? highlight,
    Color? shadow,
    Color? disabledBackground,
    Color? disabledForeground,
  }) {
    return InkColors(
      scaffold: scaffold ?? this.scaffold,
      surface: surface ?? this.surface,
      chrome: chrome ?? this.chrome,
      container: container ?? this.container,
      onSurface: onSurface ?? this.onSurface,
      onSurfaceMuted: onSurfaceMuted ?? this.onSurfaceMuted,
      outline: outline ?? this.outline,
      scrim: scrim ?? this.scrim,
      highlight: highlight ?? this.highlight,
      shadow: shadow ?? this.shadow,
      disabledBackground: disabledBackground ?? this.disabledBackground,
      disabledForeground: disabledForeground ?? this.disabledForeground,
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
      chrome: Color.lerp(chrome, other.chrome, t)!,
      container: Color.lerp(container, other.container, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      onSurfaceMuted: Color.lerp(onSurfaceMuted, other.onSurfaceMuted, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
      highlight: Color.lerp(highlight, other.highlight, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      disabledBackground: Color.lerp(
        disabledBackground,
        other.disabledBackground,
        t,
      )!,
      disabledForeground: Color.lerp(
        disabledForeground,
        other.disabledForeground,
        t,
      )!,
    );
  }
}
