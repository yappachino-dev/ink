import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ink/core/config/user_config.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'network_state_provider.g.dart';

class NetworkState {
  const NetworkState({
    required this.isConnected,
    required this.isAllowedToSync,
  });

  final bool isConnected;
  final bool isAllowedToSync;
}

@Riverpod(keepAlive: true)
Stream<List<ConnectivityResult>> connectivityStream(Ref ref) async* {
  yield await Connectivity().checkConnectivity();
  yield* Connectivity().onConnectivityChanged;
}

@Riverpod(keepAlive: true)
NetworkState networkState(Ref ref) {
  final localOnly = ref.watch(userPreferencesProvider).localOnly;
  final connectivityAsync = ref.watch(connectivityStreamProvider);

  final isConnected = connectivityAsync.maybeWhen(
    data: _hasNetworkConnection,
    orElse: () => false,
  );

  return NetworkState(
    isConnected: isConnected,
    isAllowedToSync: !localOnly && isConnected,
  );
}

bool _hasNetworkConnection(List<ConnectivityResult> connectivity) =>
    connectivity.contains(ConnectivityResult.wifi) ||
    connectivity.contains(ConnectivityResult.mobile);
