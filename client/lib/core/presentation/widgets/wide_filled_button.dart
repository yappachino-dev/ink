import 'package:flutter/material.dart';
import 'package:ink/core/presentation/app_sizes.dart' as sizes;

class WideFilledButton extends StatelessWidget {
  const WideFilledButton({
    required this.onPressed,
    required this.child,
    super.key,
  });

  final VoidCallback? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        minimumSize: sizes.wideButtonLarge,
      ),
      child: child,
    );
  }
}
