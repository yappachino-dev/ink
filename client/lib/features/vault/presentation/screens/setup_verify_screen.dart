import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/presentation/app_sizes.dart' as sizes;
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/widgets/app_logo.dart';
import 'package:ink/core/presentation/widgets/back_app_bar.dart';
import 'package:ink/core/presentation/widgets/scaffold/spaced_scaffold.dart';
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
  bool _isError = false;
  bool _isButtonEnabled = false;
  List<String> _currentValues = [];

  void _handleVerify() {
    final success = ref
        .read(vaultSetupProvider.notifier)
        .verifyPhrase(_currentValues);

    if (success) {
      unawaited(ref.read(vaultSetupProvider.notifier).commitSetup());
    } else {
      setState(() => _isError = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(vaultSetupProvider);

    return SpacedScaffold(
      appBar: const BackAppBar(),
      children: [
        const _Header(),

        RecoveryVerifyForm(
          indices: state.verifyIndices,
          isError: _isError,
          onChanged: (values) => setState(() {
            _isError = false;
            _currentValues = values;
            _isButtonEnabled = !values.any((v) => v.isEmpty);
          }),
        ),

        const AppLogo(size: LogoSize.large),

        WideFilledButton(
          onPressed: !_isError && _isButtonEnabled ? _handleVerify : null,
          child: Text(context.t.common.kContinue),
        ),
      ],
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
      ],
    );
  }
}
