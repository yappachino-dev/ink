import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/app/database/database_provider.dart';
import 'package:ink/core/presentation/app_sizes.dart' as sizes;
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/widgets/flow_scaffold.dart';
import 'package:ink/core/presentation/widgets/wide_filled_button.dart';
import 'package:ink/core/services/sync/sync_storage.dart';
import 'package:ink/features/vault/domain/entities/key_type.dart';
import 'package:ink/features/vault/domain/vault_state.dart';
import 'package:ink/features/vault/presentation/navigation/vault_unlock_routes.dart';
import 'package:ink/features/vault/presentation/notifiers/vault_notifier.dart';
import 'package:ink/features/vault/presentation/widgets/unlock_method.dart';
import 'package:ink/i18n/strings.g.dart';

class UnlockMethodScreen extends ConsumerStatefulWidget {
  const UnlockMethodScreen({super.key});

  @override
  ConsumerState<UnlockMethodScreen> createState() => _UnlockMethodScreenState();
}

class _UnlockMethodScreenState extends ConsumerState<UnlockMethodScreen> {
  String? _selectedMethodId;

  Future<void> _onSubmit() async {
    // TO-DO: replace String with KeyType once
    // nuke database is not required anymore
    switch (_selectedMethodId) {
      case 'pin':
        unawaited(const UnlockPinRoute().push<void>(context));
      case 'pattern':
        unawaited(const UnlockPatternRoute().push<void>(context));
      case 'phrase':
        unawaited(const UnlockRecoveryRoute().push<void>(context));
      case 'nuke':
        await ref.read(appDatabaseProvider).resetDatabase();
        await ref.read(syncStorageProvider).saveSyncCursor(0);
        ref.invalidate(vaultProvider);
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(vaultProvider);
    var methods = <KeyType>[];

    if (state is VaultLocked) {
      methods = state.unlockMethods;
    }

    return FlowScaffold(
      showAppBar: false,
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

          if (methods.contains(KeyType.pin))
            UnlockMethod(
              title: context.t.vault.methods.pin.title,
              subtitle: context.t.vault.methods.pin.subtitle,
              isSelected: _selectedMethodId == 'pin',
              onTap: () => setState(
                () => _selectedMethodId = 'pin',
              ),
            ),

          if (methods.contains(KeyType.pattern))
            UnlockMethod(
              title: context.t.vault.methods.pattern.title,
              subtitle: context.t.vault.methods.pattern.subtitle,
              isSelected: _selectedMethodId == 'pattern',
              onTap: () => setState(
                () => _selectedMethodId = 'pattern',
              ),
            ),

          if (methods.contains(KeyType.recoveryPhrase))
            UnlockMethod(
              title: context.t.vault.methods.seed.title,
              subtitle: context.t.vault.methods.seed.subtitle,
              isSelected: _selectedMethodId == 'phrase',
              onTap: () => setState(
                () => _selectedMethodId = 'phrase',
              ),
            ),

          UnlockMethod(
            title: 'nuke database',
            subtitle: 'nuke database',
            isSelected: _selectedMethodId == 'nuke',
            onTap: () => setState(
              () => _selectedMethodId = 'nuke',
            ),
          ),

          const Spacer(),

          WideFilledButton(
            onPressed: _selectedMethodId != null ? _onSubmit : null,
            child: Text(context.t.common.next),
          ),
        ],
      ),
    );
  }
}
