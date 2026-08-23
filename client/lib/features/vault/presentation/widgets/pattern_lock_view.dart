import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ink/core/presentation/app_animations.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:pattern_lock/pattern_lock.dart';

class PatternLockView extends StatefulWidget {
  const PatternLockView({
    required this.onPatternChanged,
    this.onPatternTooShort,
    this.height = 300,
    super.key,
  });

  final ValueChanged<List<int>?> onPatternChanged;
  final VoidCallback? onPatternTooShort;
  final double height;

  @override
  State<PatternLockView> createState() => _PatternLockViewState();
}

class _PatternLockViewState extends State<PatternLockView>
    with SingleTickerProviderStateMixin {
  bool _isError = false;
  late final AnimationController _shakeController;

  @override
  void initState() {
    super.initState();

    _shakeController = AnimationController(
      duration: AppDurations.slow,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();

    super.dispose();
  }

  Future<void> _triggerError() async {
    setState(() => _isError = true);
    widget.onPatternChanged(null);

    await _shakeController.forward(from: 0);

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => _isError = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        final offset = sin(_shakeController.value * pi * 3) * 8;

        return Transform.translate(
          offset: Offset(offset, 0),
          child: child,
        );
      },
      child: SizedBox(
        height: widget.height,
        child: PatternLock(
          selectedColor: _isError
              ? context.colorScheme.error
              : context.colorScheme.primary,
          notSelectedColor: context.colorScheme.onSurfaceVariant,
          onInputComplete: (input) async {
            if (input.length < 4) {
              widget.onPatternTooShort?.call();
              await _triggerError();
            } else {
              setState(() => _isError = false);
              widget.onPatternChanged(input);
            }
          },
        ),
      ),
    );
  }
}
