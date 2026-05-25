// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(connectivityStream)
final connectivityStreamProvider = ConnectivityStreamProvider._();

final class ConnectivityStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ConnectivityResult>>,
          List<ConnectivityResult>,
          Stream<List<ConnectivityResult>>
        >
    with
        $FutureModifier<List<ConnectivityResult>>,
        $StreamProvider<List<ConnectivityResult>> {
  ConnectivityStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'connectivityStreamProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$connectivityStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<ConnectivityResult>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ConnectivityResult>> create(Ref ref) {
    return connectivityStream(ref);
  }
}

String _$connectivityStreamHash() =>
    r'ebdc4f33ceefe1a0a06b3a2e0f447646dfd46d0f';

@ProviderFor(networkState)
final networkStateProvider = NetworkStateProvider._();

final class NetworkStateProvider
    extends $FunctionalProvider<NetworkState, NetworkState, NetworkState>
    with $Provider<NetworkState> {
  NetworkStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'networkStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$networkStateHash();

  @$internal
  @override
  $ProviderElement<NetworkState> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NetworkState create(Ref ref) {
    return networkState(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NetworkState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NetworkState>(value),
    );
  }
}

String _$networkStateHash() => r'd6dd5a514cf103222f2fed19ad46ca6dd32ba432';
