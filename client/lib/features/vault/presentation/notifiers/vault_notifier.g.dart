// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vault_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(VaultNotifier)
final vaultProvider = VaultNotifierProvider._();

final class VaultNotifierProvider
    extends $NotifierProvider<VaultNotifier, VaultState> {
  VaultNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vaultProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vaultNotifierHash();

  @$internal
  @override
  VaultNotifier create() => VaultNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VaultState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VaultState>(value),
    );
  }
}

String _$vaultNotifierHash() => r'a2d933ee0a4ffff260fb8d3f89dc036917447fd8';

abstract class _$VaultNotifier extends $Notifier<VaultState> {
  VaultState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<VaultState, VaultState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<VaultState, VaultState>,
              VaultState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
