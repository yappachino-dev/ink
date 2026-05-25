import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ink/core/presentation/app_sizes.dart' as sizes;
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/widgets/app_logo.dart';
import 'package:ink/core/presentation/widgets/flow_scaffold.dart';
import 'package:ink/i18n/strings.g.dart';

class FatalScreen extends StatefulWidget {
  const FatalScreen({super.key});

  @override
  State<FatalScreen> createState() => _FatalScreenState();
}

class _FatalScreenState extends State<FatalScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    unawaited(_controller.forward());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FlowScaffold(
      showAppBar: false,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppLogo(size: LogoSize.small),

                const SizedBox(height: 24),

                Text(
                  context.t.vault.fatal.title,
                  style: context.textTheme.displayLarge,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: sizes.betweenTitleAndSub),

                Text(
                  context.t.vault.fatal.subtitle,
                  style: context.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
