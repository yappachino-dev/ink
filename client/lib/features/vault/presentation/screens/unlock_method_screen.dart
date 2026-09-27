import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/theme/tokens.dart';
import 'package:ink/core/presentation/widgets/scaffold/spaced_scaffold.dart';
import 'package:ink/core/presentation/widgets/wide_filled_button.dart';
import 'package:ink/features/vault/domain/entities/key_type.dart';
import 'package:ink/features/vault/domain/vault_state.dart';
import 'package:ink/features/vault/presentation/navigation/vault_unlock_routes.dart';
import 'package:ink/features/vault/presentation/notifiers/vault_notifier.dart';
import 'package:ink/features/vault/presentation/widgets/unlock_method.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';

class UnlockMethodScreen extends ConsumerStatefulWidget {
  const UnlockMethodScreen({super.key});

  @override
  ConsumerState<UnlockMethodScreen> createState() => _UnlockMethodScreenState();
}

class _UnlockMethodScreenState extends ConsumerState<UnlockMethodScreen> {
  KeyType? _selectedMethod;

  Future<void> _onSubmit() async {
    switch (_selectedMethod) {
      case KeyType.pin:
        unawaited(const UnlockPinRoute().push<void>(context));
      case KeyType.pattern:
        unawaited(const UnlockPatternRoute().push<void>(context));
      case KeyType.recoveryPhrase:
        unawaited(const UnlockRecoveryRoute().push<void>(context));
      case null:
      case KeyType.unknown:
        break;
    }
  }

  void _selectMethod(KeyType type) => setState(() => _selectedMethod = type);

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(vaultProvider);
    var methods = <KeyType>[];

    if (state is VaultLocked) {
      methods = state.unlockMethods;
    }

    return SpacedScaffold(
      children: [
        Column(
          children: [
            const _Header(),

            const SizedBox(height: AppSpacing.huge),

            if (methods.contains(KeyType.pin))
              UnlockMethod(
                title: context.t.vault.methods.pin.title,
                subtitle: context.t.vault.methods.pin.subtitle,
                isSelected: _selectedMethod == KeyType.pin,
                onTap: () => _selectMethod(KeyType.pin),
              ),

            if (methods.contains(KeyType.pattern))
              UnlockMethod(
                title: context.t.vault.methods.pattern.title,
                subtitle: context.t.vault.methods.pattern.subtitle,
                isSelected: _selectedMethod == KeyType.pattern,
                onTap: () => _selectMethod(KeyType.pattern),
              ),

            if (methods.contains(KeyType.recoveryPhrase))
              UnlockMethod(
                title: context.t.vault.methods.seed.title,
                subtitle: context.t.vault.methods.seed.subtitle,
                isSelected: _selectedMethod == KeyType.recoveryPhrase,
                onTap: () => _selectMethod(KeyType.recoveryPhrase),
              ),
          ],
        ),

        WideFilledButton(
          onPressed: _selectedMethod != null ? _onSubmit : null,
          child: Text(context.t.common.next),
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
          context.t.vault.methods.title,
          style: context.textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppSpacing.xs),

        Text(
          context.t.vault.methods.subtitle,
          style: context.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
