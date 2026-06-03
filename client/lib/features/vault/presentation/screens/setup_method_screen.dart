import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/presentation/app_sizes.dart' as sizes;
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/widgets/flow_scaffold.dart';
import 'package:ink/core/presentation/widgets/wide_filled_button.dart';
import 'package:ink/features/vault/domain/entities/key_type.dart';
import 'package:ink/features/vault/presentation/navigation/vault_setup_routes.dart';
import 'package:ink/features/vault/presentation/widgets/unlock_method.dart';
import 'package:ink/i18n/strings.g.dart';

class SetupMethodScreen extends ConsumerStatefulWidget {
  const SetupMethodScreen({super.key});

  @override
  ConsumerState<SetupMethodScreen> createState() => _SetupMethodScreenState();
}

class _SetupMethodScreenState extends ConsumerState<SetupMethodScreen> {
  KeyType? _selectedMethod;

  void _onSubmit() {
    switch (_selectedMethod) {
      case KeyType.pin:
        unawaited(const SetupPinRoute().push<void>(context));
      case KeyType.pattern:
        unawaited(const SetupPatternRoute().push<void>(context));
      case null:
      case KeyType.unknown:
      case KeyType.recoveryPhrase:
        break;
    }
  }

  void _selectMethod(KeyType type) => setState(() => _selectedMethod = type);

  @override
  Widget build(BuildContext context) {
    return FlowScaffold(
      body: Column(
        children: [
          Text(
            context.t.vault.methods.title,
            style: context.textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: sizes.betweenTitleAndSub),

          Text(
            context.t.vault.methods.subtitle,
            style: context.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 48),

          UnlockMethod(
            title: context.t.vault.methods.pin.title,
            subtitle: context.t.vault.methods.pin.subtitle,
            isSelected: _selectedMethod == KeyType.pin,
            onTap: () => _selectMethod(KeyType.pin),
          ),

          UnlockMethod(
            title: context.t.vault.methods.pattern.title,
            subtitle: context.t.vault.methods.pattern.subtitle,
            isSelected: _selectedMethod == KeyType.pattern,
            onTap: () => _selectMethod(KeyType.pattern),
          ),

          const Spacer(),

          WideFilledButton(
            onPressed: _selectedMethod != null ? _onSubmit : null,
            child: Text(context.t.common.next),
          ),
        ],
      ),
    );
  }
}
