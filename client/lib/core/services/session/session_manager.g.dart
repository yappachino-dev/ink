// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SessionManager)
final sessionManagerProvider = SessionManagerProvider._();

final class SessionManagerProvider
    extends $NotifierProvider<SessionManager, SessionState> {
  SessionManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionManagerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionManagerHash();

  @$internal
  @override
  SessionManager create() => SessionManager();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SessionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SessionState>(value),
    );
  }
}

String _$sessionManagerHash() => r'8c251cdc078ac5bab3f12ea39311b59b0699faaa';

abstract class _$SessionManager extends $Notifier<SessionState> {
  SessionState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SessionState, SessionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SessionState, SessionState>,
              SessionState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(authSession)
final authSessionProvider = AuthSessionProvider._();

final class AuthSessionProvider
    extends $FunctionalProvider<AuthSession, AuthSession, AuthSession>
    with $Provider<AuthSession> {
  AuthSessionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authSessionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authSessionHash();

  @$internal
  @override
  $ProviderElement<AuthSession> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthSession create(Ref ref) {
    return authSession(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthSession value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthSession>(value),
    );
  }
}

String _$authSessionHash() => r'3163f30a65d7bc7a0241c95447ec0cf428761e32';

@ProviderFor(cryptoSession)
final cryptoSessionProvider = CryptoSessionProvider._();

final class CryptoSessionProvider
    extends $FunctionalProvider<CryptoSession, CryptoSession, CryptoSession>
    with $Provider<CryptoSession> {
  CryptoSessionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cryptoSessionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cryptoSessionHash();

  @$internal
  @override
  $ProviderElement<CryptoSession> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CryptoSession create(Ref ref) {
    return cryptoSession(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CryptoSession value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CryptoSession>(value),
    );
  }
}

String _$cryptoSessionHash() => r'3f0da01a5873179c7cbc73e1c8b5d0cd9a502abe';

@ProviderFor(sessionController)
final sessionControllerProvider = SessionControllerProvider._();

final class SessionControllerProvider
    extends
        $FunctionalProvider<
          SessionController,
          SessionController,
          SessionController
        >
    with $Provider<SessionController> {
  SessionControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionControllerHash();

  @$internal
  @override
  $ProviderElement<SessionController> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SessionController create(Ref ref) {
    return sessionController(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SessionController value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SessionController>(value),
    );
  }
}

String _$sessionControllerHash() => r'1f991dc89d3785dbf0cd61bb8f83e318e0c894af';

@ProviderFor(isMasterKeyPresent)
final isMasterKeyPresentProvider = IsMasterKeyPresentProvider._();

final class IsMasterKeyPresentProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  IsMasterKeyPresentProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isMasterKeyPresentProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isMasterKeyPresentHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isMasterKeyPresent(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isMasterKeyPresentHash() =>
    r'6b045e1b87a77349e97a1ce5617bd6d8a50bdfa3';

@ProviderFor(isAccessTokenPresent)
final isAccessTokenPresentProvider = IsAccessTokenPresentProvider._();

final class IsAccessTokenPresentProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  IsAccessTokenPresentProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isAccessTokenPresentProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isAccessTokenPresentHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isAccessTokenPresent(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isAccessTokenPresentHash() =>
    r'970e0ebfad55bdbcfd49c286a41f119844bbe497';
