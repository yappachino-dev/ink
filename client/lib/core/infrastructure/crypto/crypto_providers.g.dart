// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crypto_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(encryptionService)
final encryptionServiceProvider = EncryptionServiceProvider._();

final class EncryptionServiceProvider
    extends
        $FunctionalProvider<
          EncryptionService,
          EncryptionService,
          EncryptionService
        >
    with $Provider<EncryptionService> {
  EncryptionServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'encryptionServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$encryptionServiceHash();

  @$internal
  @override
  $ProviderElement<EncryptionService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EncryptionService create(Ref ref) {
    return encryptionService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EncryptionService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EncryptionService>(value),
    );
  }
}

String _$encryptionServiceHash() => r'df85d0b9a2a13da04185d493b07dfc8d8cd34f3a';

@ProviderFor(derivationService)
final derivationServiceProvider = DerivationServiceProvider._();

final class DerivationServiceProvider
    extends
        $FunctionalProvider<
          DerivationService,
          DerivationService,
          DerivationService
        >
    with $Provider<DerivationService> {
  DerivationServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'derivationServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$derivationServiceHash();

  @$internal
  @override
  $ProviderElement<DerivationService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DerivationService create(Ref ref) {
    return derivationService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DerivationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DerivationService>(value),
    );
  }
}

String _$derivationServiceHash() => r'53598ff70a2d11154355bf36911bc2340c05bab3';

@ProviderFor(randomService)
final randomServiceProvider = RandomServiceProvider._();

final class RandomServiceProvider
    extends $FunctionalProvider<RandomService, RandomService, RandomService>
    with $Provider<RandomService> {
  RandomServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'randomServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$randomServiceHash();

  @$internal
  @override
  $ProviderElement<RandomService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RandomService create(Ref ref) {
    return randomService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RandomService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RandomService>(value),
    );
  }
}

String _$randomServiceHash() => r'879c0cd69fd87941ea896fad152c450d516546e1';
