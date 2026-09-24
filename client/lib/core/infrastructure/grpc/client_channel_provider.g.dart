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
    extends
        $FunctionalProvider<
          grpc_internal.ClientChannel,
          grpc_internal.ClientChannel,
          grpc_internal.ClientChannel
        >
    with $Provider<grpc_internal.ClientChannel> {
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
  $ProviderElement<grpc_internal.ClientChannel> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  grpc_internal.ClientChannel create(Ref ref) {
    return clientChannel(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(grpc_internal.ClientChannel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<grpc_internal.ClientChannel>(value),
    );
  }
}

String _$clientChannelHash() => r'fd70f126e7db13222bdd75fa95c8e40b9ef4c905';
