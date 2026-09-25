// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vault_setup_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(VaultSetup)
final vaultSetupProvider = VaultSetupProvider._();

final class VaultSetupProvider
    extends $NotifierProvider<VaultSetup, VaultSetupData> {
  VaultSetupProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vaultSetupProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vaultSetupHash();

  @$internal
  @override
  VaultSetup create() => VaultSetup();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VaultSetupData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VaultSetupData>(value),
    );
  }
}

String _$vaultSetupHash() => r'd2d7671d47adbdd5eea26a375cd28d2051d3d541';

abstract class _$VaultSetup extends $Notifier<VaultSetupData> {
  VaultSetupData build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<VaultSetupData, VaultSetupData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<VaultSetupData, VaultSetupData>,
              VaultSetupData,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
