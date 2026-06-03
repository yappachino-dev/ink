import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/presentation/app_sizes.dart' as sizes;
import 'package:ink/core/presentation/extensions/app_snack_bar_extension.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/widgets/app_logo.dart';
import 'package:ink/core/presentation/widgets/flow_scaffold.dart';
import 'package:ink/core/presentation/widgets/wide_filled_button.dart';
import 'package:ink/features/vault/domain/constants.dart' as constants;
import 'package:ink/features/vault/presentation/notifiers/vault_unlock_notifier.dart';
import 'package:ink/features/vault/presentation/widgets/pattern_lock_view.dart';
import 'package:ink/i18n/strings.g.dart';

class UnlockPatternScreen extends ConsumerStatefulWidget {
  const UnlockPatternScreen({super.key});

  @override
  ConsumerState<UnlockPatternScreen> createState() =>
      _UnlockPatternScreenState();
}

class _UnlockPatternScreenState extends ConsumerState<UnlockPatternScreen> {
  List<int>? _pattern;

  void _onSubmit() =>
      ref.read(vaultUnlockProvider.notifier).unlockWithPattern(_pattern!);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, _) =>
          didPop ? ref.invalidate(vaultUnlockProvider) : null,
      child: FlowScaffold(
        body: Column(
          children: [
            Text(
              context.t.vault.unlock.pattern.title,
              style: context.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: sizes.betweenTitleAndSub),

            Text(
              context.t.vault.unlock.pattern.description,
              style: context.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),

            const Spacer(),

            PatternLockView(
              onPatternChanged: (pattern) => setState(() => _pattern = pattern),
              onPatternTooShort: () => context.showSnackbarError(
                context.t.vault.unlock.pattern.errorShort,
              ),
            ),

            const Spacer(),

            const AppLogo(size: LogoSize.large),

            const Spacer(),

            WideFilledButton(
              onPressed:
                  (_pattern != null &&
                      _pattern!.length >= constants.minPatternLength)
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
