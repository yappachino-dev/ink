import 'package:flutter/material.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';

class SettingsCard extends StatelessWidget {
  const SettingsCard({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.customColors.containerColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(children: children),
    );
  }
}
