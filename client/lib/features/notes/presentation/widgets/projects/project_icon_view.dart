import 'package:ink/features/notes/presentation/constants/project_constants.dart';
import 'package:material_ui/material_ui.dart';

/// A notebook's mark, drawn as a themed icon rather than an emoji.
///
/// Emoji rendered differently per platform, ignored the app's colours, and
/// broke the row alignment. Every notebook now uses the same Material glyph set
/// as the rest of the chrome.
class ProjectIconView extends StatelessWidget {
  const ProjectIconView({
    required this.value,
    this.size = 20,
    this.color,
    super.key,
  });

  /// The stored value: a [ProjectIcon] key, or a legacy emoji glyph.
  final String value;

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Icon(projectIcon(value).icon, size: size, color: color);
  }
}
