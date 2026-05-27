import 'package:flutter/foundation.dart';
import 'package:grpc/grpc.dart';
import 'package:ink/core/config/app_config_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'client_channel_provider.g.dart';

@Riverpod(keepAlive: true)
ClientChannel clientChannel(Ref ref) {
  final config = ref.watch(appConfigProvider);

  final useInsecure = !kReleaseMode && config.environment == 'development';

  return ClientChannel(
    config.grpcHost,
    port: config.grpcPort,
    options: ChannelOptions(
      credentials: useInsecure
          ? const ChannelCredentials.insecure()
          : const ChannelCredentials.secure(),
    ),
  );
}
