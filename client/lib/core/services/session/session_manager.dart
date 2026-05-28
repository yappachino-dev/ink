import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/services/session/auth_session.dart';
import 'package:ink/core/services/session/crypto_session.dart';
import 'package:ink/core/services/session/session_controller.dart';
import 'package:ink/core/services/session/session_exceptions.dart';
import 'package:ink/core/services/session/session_repository.dart';
import 'package:ink/core/services/session/session_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session_manager.g.dart';

@Riverpod(keepAlive: true)
class SessionManager extends _$SessionManager
    implements AuthSession, CryptoSession, SessionController {
  @override
  SessionState build() {
    unawaited(_loadTokens());
    return const SessionState(isLoaded: false);
  }

  Future<void> _loadTokens() async {
    final repo = ref.read(sessionRepositoryProvider);

    final accessToken = await repo.readAccessToken();
    final refreshToken = await repo.readRefreshToken();

    state = state.copyWith(
      accessToken: accessToken,
      refreshToken: refreshToken,
      isLoaded: true,
    );
  }

  @override
  String? get accessToken => state.accessToken;

  @override
  String? get refreshToken => state.refreshToken;

  @override
  Uint8List get masterKey {
    if (state.masterKey == null) throw const SessionLockedException();
    return state.masterKey!;
  }

  @override
  Future<void> setAuthTokens(String accessToken, String refreshToken) async {
    state = state.copyWith(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    final repo = ref.read(sessionRepositoryProvider);
    await repo.saveAccessToken(accessToken);
    await repo.saveRefreshToken(refreshToken);
  }

  @override
  Future<void> clearAccessToken() async {
    state = state.copyWith(accessToken: null);
    await ref.read(sessionRepositoryProvider).clearAccessToken();
  }

  @override
  Future<void> clearRefreshToken() async {
    state = state.copyWith(refreshToken: null);
    await ref.read(sessionRepositoryProvider).clearRefreshToken();
  }

  @override
  void setMasterKey(Uint8List key) => state = state.copyWith(masterKey: key);

  @override
  void clearMasterKey() {
    if (state.masterKey != null) {
      for (var i = 0; i < state.masterKey!.length; i++) {
        state.masterKey![i] = 0;
      }
    }

    state = state.copyWith(masterKey: null);
  }
}

@Riverpod(keepAlive: true)
AuthSession authSession(Ref ref) => ref.watch(sessionManagerProvider.notifier);

@Riverpod(keepAlive: true)
CryptoSession cryptoSession(Ref ref) =>
    ref.watch(sessionManagerProvider.notifier);

@Riverpod(keepAlive: true)
SessionController sessionController(Ref ref) =>
    ref.watch(sessionManagerProvider.notifier);

@Riverpod(keepAlive: true)
bool isSessionLoaded(Ref ref) => ref.watch(
  sessionManagerProvider.select((state) => state.isLoaded),
);

@Riverpod(keepAlive: true)
bool isMasterKeyPresent(Ref ref) => ref.watch(
  sessionManagerProvider.select((state) => state.masterKey != null),
);

@Riverpod(keepAlive: true)
bool isAccessTokenPresent(Ref ref) => ref.watch(
  sessionManagerProvider.select((state) => state.accessToken != null),
);
