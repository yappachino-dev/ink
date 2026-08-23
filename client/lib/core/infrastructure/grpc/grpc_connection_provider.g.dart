// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grpc_connection_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(grpcConnection)
final grpcConnectionProvider = GrpcConnectionProvider._();

final class GrpcConnectionProvider
    extends $FunctionalProvider<GrpcConnection, GrpcConnection, GrpcConnection>
    with $Provider<GrpcConnection> {
  GrpcConnectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'grpcConnectionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$grpcConnectionHash();

  @$internal
  @override
  $ProviderElement<GrpcConnection> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GrpcConnection create(Ref ref) {
    return grpcConnection(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GrpcConnection value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GrpcConnection>(value),
    );
  }
}

String _$grpcConnectionHash() => r'8155ef62cccf14ee0b42338e7be5658f9c5c9412';

@ProviderFor(grpcAuthConnection)
final grpcAuthConnectionProvider = GrpcAuthConnectionProvider._();

final class GrpcAuthConnectionProvider
    extends $FunctionalProvider<GrpcConnection, GrpcConnection, GrpcConnection>
    with $Provider<GrpcConnection> {
  GrpcAuthConnectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'grpcAuthConnectionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$grpcAuthConnectionHash();

  @$internal
  @override
  $ProviderElement<GrpcConnection> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GrpcConnection create(Ref ref) {
    return grpcAuthConnection(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GrpcConnection value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GrpcConnection>(value),
    );
  }
}

String _$grpcAuthConnectionHash() =>
    r'9f17c49ccec7bb738ac139719f38eb947668865d';
