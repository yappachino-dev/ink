import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/features/vault/presentation/notifiers/vault_unlock_notifier.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';

/// Shown on unlock screens while the progressive lockout is active: displays a
/// ticking countdown and reports whether submissions must be blocked.
class UnlockThrottleMessage extends ConsumerStatefulWidget {
  const UnlockThrottleMessage({super.key});

  /// Whether the lockout in [state] still blocks unlock attempts.
  static bool isLocked(VaultUnlockData state) {
    final until = state.lockedUntil;
    return until != null && DateTime.now().isBefore(until);
  }

  @override
  ConsumerState<UnlockThrottleMessage> createState() =>
      _UnlockThrottleMessageState();
}

class _UnlockThrottleMessageState extends ConsumerState<UnlockThrottleMessage> {
  Timer? _ticker;

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lockedUntil = ref.watch(
      vaultUnlockProvider.select((state) => state.lockedUntil),
    );

    if (lockedUntil == null || !DateTime.now().isBefore(lockedUntil)) {
      _ticker?.cancel();
      _ticker = null;
      return const SizedBox.shrink();
    }

    // Keep a 1s ticker alive only for the duration of the lockout so the
    // countdown updates and the message disappears when it elapses.
    _ticker ??= Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });

    final remaining = lockedUntil.difference(DateTime.now());
    return Text(
      context.t.vault.unlock.throttled(
        seconds: remaining.inSeconds.clamp(1, remaining.inSeconds),
      ),
      style: context.textTheme.bodyMedium?.copyWith(
        color: context.colorScheme.error,
      ),
      textAlign: TextAlign.center,
    );
  }
}
