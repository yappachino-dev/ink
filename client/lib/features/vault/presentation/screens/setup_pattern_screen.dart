import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/presentation/app_sizes.dart' as sizes;
import 'package:ink/core/presentation/extensions/app_snack_bar_extension.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/widgets/app_logo.dart';
import 'package:ink/core/presentation/widgets/flow_scaffold.dart';
import 'package:ink/core/presentation/widgets/wide_filled_button.dart';
import 'package:ink/features/vault/presentation/navigation/vault_setup_routes.dart';
import 'package:ink/features/vault/presentation/notifiers/vault_setup_notifier.dart';
import 'package:ink/features/vault/presentation/widgets/pattern_lock_view.dart';
import 'package:ink/i18n/strings.g.dart';

class SetupPatternScreen extends ConsumerStatefulWidget {
  const SetupPatternScreen({super.key});

  @override
  ConsumerState<SetupPatternScreen> createState() => _SetupPatternScreenState();
}

class _SetupPatternScreenState extends ConsumerState<SetupPatternScreen> {
  List<int>? _pattern;

  void _onSubmit() {
    ref.read(vaultSetupProvider.notifier).setupPattern(_pattern!);
    unawaited(const SetupRecoveryRoute().push<void>(context));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, _) =>
          didPop ? ref.read(vaultSetupProvider.notifier).abortFlow() : null,
      child: FlowScaffold(
        body: Column(
          children: [
            Text(
              context.t.vault.setup.pattern.title,
              style: context.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: sizes.betweenTitleAndSub),

            Text(
              context.t.vault.setup.pattern.description,
              style: context.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),

            const Spacer(),

            PatternLockView(
              onPatternChanged: (pattern) => setState(() => _pattern = pattern),
              onPatternTooShort: () => context.showSnackbarError(
                context.t.vault.setup.pattern.errorShort,
              ),
            ),

            const Spacer(),

            const AppLogo(size: LogoSize.large),

            const Spacer(),

            WideFilledButton(
              onPressed: (_pattern != null && _pattern!.length >= 4)
                  ? _onSubmit
                  : null,
              child: Text(context.t.common.kContinue),
            ),
          ],
        ),
      ),
    );
  }
}
