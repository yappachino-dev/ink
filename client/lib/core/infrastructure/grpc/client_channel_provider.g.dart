// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_channel_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(clientChannel)
final clientChannelProvider = ClientChannelProvider._();

final class ClientChannelProvider
    extends $FunctionalProvider<ClientChannel, ClientChannel, ClientChannel>
    with $Provider<ClientChannel> {
  ClientChannelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clientChannelProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clientChannelHash();

  @$internal
  @override
  $ProviderElement<ClientChannel> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ClientChannel create(Ref ref) {
    return clientChannel(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ClientChannel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ClientChannel>(value),
    );
  }
}

String _$clientChannelHash() => r'6b3d816d58c64cf5630c464fbcfb665e938b6c03';
