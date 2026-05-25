import 'package:flutter/material.dart';
import 'package:ink/core/presentation/extensions/navigation_helper.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';

class BackAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BackAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        color: context.colorScheme.primary,
        onPressed: context.safePop,
      ),
    );
  }
}
