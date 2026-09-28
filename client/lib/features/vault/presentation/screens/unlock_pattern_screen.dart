import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/presentation/extensions/app_snack_bar_extension.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/theme/tokens.dart';
import 'package:ink/core/presentation/widgets/app_logo.dart';
import 'package:ink/core/presentation/widgets/back_app_bar.dart';
import 'package:ink/core/presentation/widgets/scaffold/spaced_scaffold.dart';
import 'package:ink/core/presentation/widgets/wide_filled_button.dart';
import 'package:ink/features/vault/domain/constants.dart' as constants;
import 'package:ink/features/vault/presentation/notifiers/vault_unlock_notifier.dart';
import 'package:ink/features/vault/presentation/widgets/pattern_lock_view.dart';
import 'package:ink/features/vault/presentation/widgets/unlock_throttle_message.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';

class UnlockPatternScreen extends ConsumerStatefulWidget {
  const UnlockPatternScreen({super.key});

  @override
  ConsumerState<UnlockPatternScreen> createState() =>
      _UnlockPatternScreenState();
}

class _UnlockPatternScreenState extends ConsumerState<UnlockPatternScreen> {
  List<int>? _pattern;

  bool _isValid() =>
      _pattern != null && _pattern!.length >= constants.minPatternLength;

  void _onSubmit() =>
      ref.read(vaultUnlockProvider.notifier).unlockWithPattern(_pattern!);

  @override
  Widget build(BuildContext context) {
    final isLocked = UnlockThrottleMessage.isLocked(
      ref.watch(vaultUnlockProvider),
    );

    return PopScope(
      onPopInvokedWithResult: (didPop, _) =>
          didPop ? ref.invalidate(vaultUnlockProvider) : null,
      child: SpacedScaffold(
        appBar: const BackAppBar(),
        children: [
          const _Header(),

          PatternLockView(
            onPatternChanged: (pattern) => setState(() => _pattern = pattern),
            onPatternTooShort: () => context.showSnackbarError(
              context.t.vault.unlock.pattern.errorShort,
            ),
          ),

          const AppLogo(size: LogoSize.large),

          if (isLocked)
            const UnlockThrottleMessage()
          else
            WideFilledButton(
              onPressed: _isValid() ? _onSubmit : null,
              child: Text(context.t.common.kContinue),
            ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          context.t.vault.unlock.pattern.title,
          style: context.textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppSpacing.xs),

        Text(
          context.t.vault.unlock.pattern.description,
          style: context.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
