
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/presentation/app_animations.dart';
import 'package:ink/core/presentation/app_sizes.dart' as sizes;
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/widgets/app_logo.dart';
import 'package:ink/core/presentation/widgets/scaffold/spaced_scaffold.dart';
import 'package:ink/core/presentation/widgets/wide_filled_button.dart';
import 'package:ink/features/vault/domain/vault_providers.dart';
import 'package:ink/features/vault/presentation/notifiers/vault_notifier.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';

class FatalScreen extends ConsumerStatefulWidget {
  const FatalScreen({super.key});

  @override
  ConsumerState<FatalScreen> createState() => _FatalScreenState();
}

class _FatalScreenState extends ConsumerState<FatalScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: AppDurations.dramatic,
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

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SpacedScaffold(
      children: [
        Center(
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
                    style: context.textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: sizes.betweenTitleAndSub),

                  Text(
                    context.t.vault.fatal.subtitle,
                    style: context.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 48),

                  // `VaultRecovery.reset()` drops the local database, zeroes
                  // the sync cursor, and clears both tokens. Note content is
                  // end-to-end encrypted, so there is no server-side copy and
                  // this cannot be undone. That makes it a destructive action,
                  // and a fatal screen is exactly where a user lands and taps
                  // whatever is offered.
                  //
                  // It stays available in debug builds for local recovery
                  // during development. In release builds it is compiled out
                  // entirely (`kDebugMode` is a compile-time constant) and the
                  // screen offers a non-destructive instruction instead.
                  if (kDebugMode)
                    WideFilledButton(
                      onPressed: () async {
                        await ref.read(vaultRecoveryProvider).reset();
                        ref.invalidate(vaultProvider);
                      },
                      child: Text(context.t.vault.fatal.devReset),
                    )
                  else
                    Text(
                      context.t.vault.fatal.releaseHint,
                      style: context.textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
