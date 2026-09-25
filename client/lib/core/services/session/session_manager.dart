import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/infrastructure/logger.dart';
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
    // Deferred to a microtask: assigning `state` while the element is still
    // building throws, and a synchronous storage read could otherwise land the
    // assignment inside build().
    unawaited(Future<void>.microtask(_loadTokens));
    return const SessionState(isLoaded: false);
  }

  /// Reads persisted tokens without ever throwing: a secure-storage failure
  /// must not leave the app stuck on the splash screen with an unhandled async
  /// error. On failure the session is still marked as loaded, with `loadError`
  /// set, so the UI can offer a retry instead of hanging.
  ///
  /// Tokens are only published when *both* reads succeed. A partial read (for
  /// example an access token read plus a failing refresh-token read) must never
  /// reach [SessionState]: `hasAccessToken` would then report a usable session
  /// that the backend cannot accept.
  Future<void> _loadTokens() async {
    final repo = ref.read(sessionRepositoryProvider);

    try {
      final accessToken = await repo.readAccessToken();
      final refreshToken = await repo.readRefreshToken();

      state = state.copyWith(
        accessToken: accessToken,
        refreshToken: refreshToken,
        isLoaded: true,
        loadError: null,
      );
    } on Object catch (error, stackTrace) {
      logger.e(
        'Failed to read persisted session tokens',
        error: error,
        stackTrace: stackTrace,
      );

      state = state.copyWith(
        accessToken: null,
        refreshToken: null,
        isLoaded: true,
        loadError: error,
      );
    }
  }

  @override
  String? get accessToken => state.accessToken;

  @override
  String? get refreshToken => state.refreshToken;

  @override
  Uint8List get masterKey {
    if (state.masterKey == null) throw const SessionLockedException();
    // Return a clone so consumers can never mutate or retain a reference to the
    // live key buffer that clearMasterKey() zeroes in place.
    return Uint8List.fromList(state.masterKey!);
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

  @override
  void retrySessionLoad() {
    // Only meaningful in the load-failure state, and the guard also prevents a
    // double tap (or a programmatic call) from starting two concurrent reads
    // against secure storage.
    if (!state.isLoaded || state.loadError == null) return;

    state = state.copyWith(isLoaded: false, loadError: null);
    unawaited(_loadTokens());
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
