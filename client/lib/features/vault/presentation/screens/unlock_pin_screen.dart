import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/presentation/app_sizes.dart' as sizes;
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/widgets/app_logo.dart';
import 'package:ink/core/presentation/widgets/back_app_bar.dart';
import 'package:ink/core/presentation/widgets/scaffold/spaced_scaffold.dart';
import 'package:ink/core/presentation/widgets/wide_filled_button.dart';
import 'package:ink/features/vault/domain/constants.dart' as constants;
import 'package:ink/features/vault/presentation/notifiers/vault_unlock_notifier.dart';
import 'package:ink/features/vault/presentation/widgets/pin_pad_view.dart';
import 'package:ink/features/vault/presentation/widgets/unlock_throttle_message.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';

class UnlockPinScreen extends ConsumerStatefulWidget {
  const UnlockPinScreen({super.key});

  @override
  ConsumerState<UnlockPinScreen> createState() => _UnlockPinScreenState();
}

class _UnlockPinScreenState extends ConsumerState<UnlockPinScreen> {
  String _pin = '';

  void _onSubmit() =>
      ref.read(vaultUnlockProvider.notifier).unlockWithPin(_pin);

  @override
  Widget build(BuildContext context) {
    final isLocked = UnlockThrottleMessage.isLocked(
      ref.watch(vaultUnlockProvider),
    );

    return SpacedScaffold(
      appBar: const BackAppBar(),
      children: [
        const _Header(),

        const AppLogo(size: LogoSize.small),

        PinPadView(
          pin: _pin,
          onPinChanged: (pin) => setState(() => _pin = pin),
        ),

        if (isLocked)
          const UnlockThrottleMessage()
        else ...[
          WideFilledButton(
            onPressed: _pin.length == constants.maxPinLength ? _onSubmit : null,
            child: Text(context.t.common.kContinue),
          ),
        ],
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
          context.t.vault.unlock.pin.title,
          style: context.textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: sizes.betweenTitleAndSub),

        Text(
          context.t.vault.unlock.pin.description,
          style: context.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
