import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/services/session/auth_session.dart';
import 'package:ink/core/services/session/crypto_session.dart';
import 'package:ink/core/services/session/session_controller.dart';
import 'package:ink/core/services/session/session_exceptions.dart';
import 'package:ink/core/services/session/session_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session_manager.g.dart';

@Riverpod(keepAlive: true)
class SessionManager extends _$SessionManager
    implements AuthSession, CryptoSession, SessionController {
  @override
  SessionState build() => const SessionState();

  @override
  String? get accessToken => state.accessToken;

  @override
  Uint8List get masterKey {
    if (state.masterKey == null) throw const SessionLockedException();

    return state.masterKey!;
  }

  @override
  void setAuthToken(String? token) =>
      state = state.copyWith(accessToken: token);

  @override
  void setMasterKey(Uint8List key) => state = state.copyWith(masterKey: key);

  @override
  void clearSession() {
    if (state.masterKey != null) {
      for (var i = 0; i < state.masterKey!.length; i++) {
        state.masterKey![i] = 0;
      }
    }

    state = const SessionState();
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
bool isMasterKeyPresent(Ref ref) => ref.watch(
  sessionManagerProvider.select((state) => state.masterKey != null),
);

@Riverpod(keepAlive: true)
bool isAccessTokenPresent(Ref ref) => ref.watch(
  sessionManagerProvider.select((state) => state.accessToken != null),
);
