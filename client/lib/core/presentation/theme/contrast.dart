import 'package:material_ui/material_ui.dart';

/// Picks legible ink for an arbitrary background.
///
/// Three call sites had grown their own copy of this: the theme's `on*` roles,
/// the logo's checkmark, and the notebook colour swatches. They disagreed - one
/// used a 0.5 luminance cut-off, one used a real contrast ratio, one used 0.45
/// with different alpha - so the same colour could produce different ink
/// depending on which surface asked.
///
/// The contrast-ratio version wins: it is the one that answers the question
/// actually being asked, and it is the one the theme's own contrast test
/// measures against.
/// [dimAlpha] is 1 by default because theme roles such as `onPrimary` have to
/// pass the contrast bar on their own; only decorative ink (a checkmark on a
/// badge) dims itself, and says so by asking for it.
Color readableInkOn(Color background, {double dimAlpha = 1}) {
  final blackRatio = contrastRatio(_black(dimAlpha), background);
  final whiteRatio = contrastRatio(Colors.white, background);

  return blackRatio >= whiteRatio ? _black(dimAlpha) : Colors.white;
}

/// WCAG relative-contrast ratio between two opaque colours.
double contrastRatio(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final lighter = la > lb ? la : lb;
  final darker = la > lb ? lb : la;
  return (lighter + 0.05) / (darker + 0.05);
}

Color _black(double alpha) =>
    alpha >= 1 ? Colors.black : Colors.black.withValues(alpha: alpha);
