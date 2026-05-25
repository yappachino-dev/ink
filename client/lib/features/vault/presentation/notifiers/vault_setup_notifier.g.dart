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

String _$vaultSetupHash() => r'bcf9b71c8c2c2caf13a592de2716dfeb80ac9093';

abstract class _$VaultSetup extends $Notifier<VaultSetupData> {
  VaultSetupData build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<VaultSetupData, VaultSetupData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<VaultSetupData, VaultSetupData>,
              VaultSetupData,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
