import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:material_ui/material_ui.dart';

class TileDivider extends StatelessWidget {
  const TileDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: context.theme.dividerColor,
    );
  }
}
