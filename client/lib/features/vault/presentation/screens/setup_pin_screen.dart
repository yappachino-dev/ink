import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/presentation/app_sizes.dart' as sizes;
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/widgets/app_logo.dart';
import 'package:ink/core/presentation/widgets/flow_scaffold.dart';
import 'package:ink/core/presentation/widgets/wide_filled_button.dart';
import 'package:ink/features/vault/domain/constants.dart' as constants;
import 'package:ink/features/vault/presentation/navigation/vault_setup_routes.dart';
import 'package:ink/features/vault/presentation/notifiers/vault_setup_notifier.dart';
import 'package:ink/features/vault/presentation/widgets/pin_pad_view.dart';
import 'package:ink/i18n/strings.g.dart';

class SetupPinScreen extends ConsumerStatefulWidget {
  const SetupPinScreen({super.key});

  @override
  ConsumerState<SetupPinScreen> createState() => _SetupPinScreenState();
}

class _SetupPinScreenState extends ConsumerState<SetupPinScreen> {
  String _pin = '';

  void _onSubmit() {
    ref.read(vaultSetupProvider.notifier).setupPin(_pin);
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
              context.t.vault.setup.pin.title,
              style: context.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: sizes.betweenTitleAndSub),

            Text(
              context.t.vault.setup.pin.description,
              style: context.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            const AppLogo(size: LogoSize.small),

            const Spacer(),

            PinPadView(
              pin: _pin,
              onPinChanged: (pin) => setState(() => _pin = pin),
            ),

            const Spacer(),

            WideFilledButton(
              onPressed: _pin.length == constants.maxPinLength
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
