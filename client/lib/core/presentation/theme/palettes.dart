import 'package:material_ui/material_ui.dart';

/// Available app palettes. Each palette is defined once and rendered in both
/// brightnesses; the **dark** rendering is the design source of truth — the
/// light variant is a tone-shifted sibling, never an inversion.
enum InkPalette {
  forest(
    id: 'forest',
    label: 'Forest',
    seed: Color(0xFF8BA88E),
  ),
  ocean(
    id: 'ocean',
    label: 'Ocean',
    seed: Color(0xFF5B9AA9),
  ),
  dusk(
    id: 'dusk',
    label: 'Dusk',
    seed: Color(0xFF9C8BC9),
  ),
  ember(
    id: 'ember',
    label: 'Ember',
    seed: Color(0xFFC9925E),
  );

  const InkPalette({
    required this.id,
    required this.label,
    required this.seed,
  });

  final String id;
  final String label;

  /// Single hue anchor for the palette; FlexColorScheme derives the full
  /// tonal scheme from it per brightness.
  final Color seed;

  static InkPalette byId(String? id) => values.firstWhere(
    (p) => p.id == id,
    orElse: () => InkPalette.forest,
  );
}
