import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/app/database/database_provider.dart';
import 'package:ink/core/presentation/app_sizes.dart' as sizes;
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/widgets/flow_scaffold.dart';
import 'package:ink/core/presentation/widgets/wide_filled_button.dart';
import 'package:ink/core/services/sync/sync_storage.dart';
import 'package:ink/features/vault/presentation/navigation/vault_setup_routes.dart';
import 'package:ink/features/vault/presentation/notifiers/vault_notifier.dart';
import 'package:ink/features/vault/presentation/widgets/unlock_method.dart';
import 'package:ink/i18n/strings.g.dart';

class SetupMethodScreen extends ConsumerStatefulWidget {
  const SetupMethodScreen({super.key});

  @override
  ConsumerState<SetupMethodScreen> createState() => _SetupMethodScreenState();
}

class _SetupMethodScreenState extends ConsumerState<SetupMethodScreen> {
  String? _selectedMethodId;

  Future<void> _onSubmit() async {
    // TO-DO: replace String with KeyType once
    // nuke database is not required anymore
    switch (_selectedMethodId) {
      case 'pin':
        unawaited(const SetupPinRoute().push<void>(context));
      case 'pattern':
        unawaited(const SetupPatternRoute().push<void>(context));
      case 'nuke':
        await ref.read(appDatabaseProvider).resetDatabase();
        await ref.read(syncStorageProvider).saveSyncCursor(0);
        ref.invalidate(vaultProvider);
      default:
    }
  }

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
            isSelected: _selectedMethodId == 'pin',
            onTap: () => setState(
              () => _selectedMethodId = 'pin',
            ),
          ),

          UnlockMethod(
            title: context.t.vault.methods.pattern.title,
            subtitle: context.t.vault.methods.pattern.subtitle,
            isSelected: _selectedMethodId == 'pattern',
            onTap: () => setState(
              () => _selectedMethodId = 'pattern',
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
