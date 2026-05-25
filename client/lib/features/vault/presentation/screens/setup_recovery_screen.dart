import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/presentation/extensions/app_snack_bar_extension.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/widgets/flow_scaffold.dart';
import 'package:ink/core/presentation/widgets/wide_filled_button.dart';
import 'package:ink/features/vault/presentation/navigation/vault_setup_routes.dart';
import 'package:ink/features/vault/presentation/notifiers/vault_setup_notifier.dart';
import 'package:ink/features/vault/presentation/widgets/recovery_phrase_display.dart';
import 'package:ink/i18n/strings.g.dart';

class SetupRecoveryScreen extends ConsumerWidget {
  const SetupRecoveryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phrase = ref.watch(vaultSetupProvider).generatedRecoveryPhrase;

    return FlowScaffold(
      body: Column(
        children: [
          Text(
            context.t.vault.setup.seed.title,
            style: context.textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.customColors.containerColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: context.colorScheme.error.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              context.t.vault.setup.seed.warning,
              style: context.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),

          const Spacer(),

          RecoveryPhraseDisplay(phrase: phrase),

          const Spacer(),

          TextButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: phrase.join(' ')));
              if (!context.mounted) return;
              context.showSnackBarInfo(context.t.vault.setup.seed.copyDone);
            },
            icon: Icon(
              Icons.copy_rounded,
              size: 18,
              color: context.colorScheme.primary,
            ),
            label: Text(
              context.t.vault.setup.seed.copy,
              style: context.textTheme.labelMedium?.copyWith(
                color: context.colorScheme.primary,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
                decorationColor: context.colorScheme.primary,
              ),
            ),
          ),

          const SizedBox(height: 20),

          WideFilledButton(
            onPressed: () => const SetupVerifyRoute().push<void>(context),
            child: Text(
              context.t.vault.setup.seed.savedButton,
            ),
          ),
        ],
      ),
    );
  }
}
