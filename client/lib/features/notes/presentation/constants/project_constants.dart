import 'package:material_ui/material_ui.dart';

/// The fixed palette a notebook can be tagged with. Stored as an ARGB int
/// inside the encrypted payload.
const List<Color> projectColors = [
  Color(0xFFFF3B30),
  Color(0xFFFF9500),
  Color(0xFFFFCC00),
  Color(0xFF34C759),
  Color(0xFF007AFF),
  Color(0xFF5856D6),
  Color(0xFFAF52DE),
  Color(0xFFFF2D55),
];

/// Icons a notebook can carry, instead of emoji.
///
/// Emoji render differently on every platform, break alignment, and do not
/// inherit the app's colour or theme. These are Material glyphs, so they sit in
/// the same visual language as the rest of the chrome and follow the palette.
///
/// The stored value is a stable key rather than a codepoint, because a
/// codepoint would tie synced data to one platform's font.
enum ProjectIcon {
  book(Icons.menu_book_outlined, Icons.menu_book),
  star(Icons.star_outline, Icons.star),
  bolt(Icons.bolt_outlined, Icons.bolt),
  bulb(Icons.lightbulb_outline, Icons.lightbulb),
  library(Icons.local_library_outlined, Icons.local_library),
  work(Icons.work_outline, Icons.work),
  run(Icons.directions_run_outlined, Icons.directions_run),
  target(Icons.track_changes_outlined, Icons.adjust),
  leaf(Icons.eco_outlined, Icons.eco),
  palette(Icons.palette_outlined, Icons.palette),
  cart(Icons.shopping_cart_outlined, Icons.shopping_cart),
  flight(Icons.flight_outlined, Icons.flight),
  home(Icons.home_outlined, Icons.home),
  health(Icons.favorite_outline, Icons.favorite),
  music(Icons.music_note_outlined, Icons.music_note);

  const ProjectIcon(this.icon, this.selectedIcon);

  final IconData icon;
  final IconData selectedIcon;

  /// The value written to storage. Stable across platforms and themes.
  String get key => name;
}

const List<ProjectIcon> projectIcons = ProjectIcon.values;

/// Resolves a stored notebook icon to a glyph, tolerating old data.
///
/// Notebooks created before this switch store an emoji glyph, and the value
/// travels inside the encrypted payload, so it can outlive any migration. An
/// unrecognised value - a legacy emoji, or a key from a future version - falls
/// back to the first icon rather than rendering a blank or a tofu box.
({IconData icon, IconData selected}) projectIcon(String value) {
  for (final candidate in projectIcons) {
    if (candidate.key == value) {
      return (icon: candidate.icon, selected: candidate.selectedIcon);
    }
  }

  return (icon: ProjectIcon.book.icon, selected: ProjectIcon.book.selectedIcon);
}
