import 'package:flutter/foundation.dart';
import 'package:grpc/grpc.dart' as grpc;
// gRPC's public export names the concrete channel rather than the abstract
// interface needed by the custom transport implementation.
// ignore: implementation_imports
import 'package:grpc/src/client/channel.dart' as grpc_internal;

import 'package:ink/core/config/app_config_provider.dart';
import 'package:ink/core/infrastructure/grpc/grpc_credentials.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'client_channel_provider.g.dart';

@Riverpod(keepAlive: true)
grpc_internal.ClientChannel clientChannel(Ref ref) {
  final config = ref.watch(appConfigProvider);
  final tls = grpcChannelCredentials(
    environment: config.environment,
    isReleaseMode: kReleaseMode,
    certificatePin: config.certificatePin,
  );

  if (tls.pinConfigured) {
    return PinnedGrpcClientChannel(
      host: config.grpcHost,
      port: config.grpcPort,
      expectedPins: tls.spkiPins,
      pinError: tls.pinError,
      trustedCertificateBytes: tls.trustedCertificateBytes,
    );
  }

  return grpc.ClientChannel(
    config.grpcHost,
    port: config.grpcPort,
    options: grpc.ChannelOptions(credentials: tls.credentials),
  );
}
