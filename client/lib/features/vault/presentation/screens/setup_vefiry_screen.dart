import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/presentation/app_sizes.dart' as sizes;
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/widgets/app_logo.dart';
import 'package:ink/core/presentation/widgets/flow_scaffold.dart';
import 'package:ink/core/presentation/widgets/wide_filled_button.dart';
import 'package:ink/features/vault/presentation/notifiers/vault_setup_notifier.dart';
import 'package:ink/features/vault/presentation/widgets/recovery_verify_form.dart';
import 'package:ink/i18n/strings.g.dart';

class SetupVerifyScreen extends ConsumerStatefulWidget {
  const SetupVerifyScreen({super.key});

  @override
  ConsumerState<SetupVerifyScreen> createState() => _SetupVerifyScreenState();
}

class _SetupVerifyScreenState extends ConsumerState<SetupVerifyScreen> {
  final _formKey = GlobalKey<RecoveryVerifyFormState>();
  bool _isError = false;
  bool _isButtonEnabled = false;

  void _handleVerify() {
    final userWords = _formKey.currentState?.values ?? [];
    final success = ref
        .read(vaultSetupProvider.notifier)
        .verifyPhrase(userWords);

    if (success) {
      unawaited(ref.read(vaultSetupProvider.notifier).commitSetup());
    } else {
      setState(() => _isError = true);
      unawaited(_formKey.currentState?.shake());
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(vaultSetupProvider);

    return FlowScaffold(
      body: Column(
        children: [
          Text(
            context.t.vault.setup.seedVerify.title,
            style: context.textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: sizes.betweenTitleAndSub),

          Text(
            context.t.vault.setup.seedVerify.description,
            style: context.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),
          const Spacer(),

          RecoveryVerifyForm(
            key: _formKey,
            indices: state.verifyIndecies,
            isError: _isError,
            onChanged: () => setState(() {
              _isError = false;
              _isButtonEnabled =
                  _formKey.currentState?.values.every((v) => v.isNotEmpty) ??
                  false;
            }),
          ),

          const SizedBox(height: 24),
          const Spacer(),

          const AppLogo(size: LogoSize.large),

          const SizedBox(height: 24),
          const Spacer(),

          WideFilledButton(
            onPressed: _isButtonEnabled ? _handleVerify : null,
            child: Text(context.t.common.kContinue),
          ),
        ],
      ),
    );
  }
}
