// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unified_auth_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'5132c28d54f343309b2d0ce357226da1ac7523a5';

@ProviderFor(unifiedAuthRepository)
final unifiedAuthRepositoryProvider = UnifiedAuthRepositoryProvider._();

final class UnifiedAuthRepositoryProvider
    extends
        $FunctionalProvider<
          UnifiedAuthRepository,
          UnifiedAuthRepository,
          UnifiedAuthRepository
        >
    with $Provider<UnifiedAuthRepository> {
  UnifiedAuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unifiedAuthRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unifiedAuthRepositoryHash();

  @$internal
  @override
  $ProviderElement<UnifiedAuthRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UnifiedAuthRepository create(Ref ref) {
    return unifiedAuthRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UnifiedAuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UnifiedAuthRepository>(value),
    );
  }
}

String _$unifiedAuthRepositoryHash() =>
    r'36556de248a5351870406c283e35f3b5654ce2c4';
