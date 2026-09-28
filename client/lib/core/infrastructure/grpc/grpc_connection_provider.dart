import 'package:grpc/grpc.dart';
// Keep the connection record aligned with the abstract channel returned by the
// custom transport provider.
// ignore_for_file: implementation_imports
import 'package:grpc/src/client/channel.dart' as grpc_internal;
import 'package:ink/core/config/env_config.dart';
import 'package:ink/core/domain/result.dart';
import 'package:ink/core/infrastructure/auth/jwt_decoder.dart';
import 'package:ink/core/infrastructure/auth/token_refresher.dart';
import 'package:ink/core/infrastructure/grpc/client_channel_provider.dart';
import 'package:ink/core/services/session/session_manager.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'grpc_connection_provider.g.dart';

typedef GrpcConnection = ({
  grpc_internal.ClientChannel channel,
  CallOptions options,
  List<ClientInterceptor> interceptors,
});

@Riverpod(keepAlive: true)
GrpcConnection grpcConnection(Ref ref) {
  final channel = ref.watch(clientChannelProvider);

  return (channel: channel, options: _timeoutOptions(), interceptors: []);
}

@Riverpod(keepAlive: true)
GrpcConnection grpcAuthConnection(Ref ref) {
  final channel = ref.watch(clientChannelProvider);

  return (
    channel: channel,
    options: _timeoutOptions(
      providers: [
        (metadata, uri) async {
          var token = ref.read(authSessionProvider).accessToken;

          if (token != null && token.isJwtExpired()) {
            final refreshToken = ref.read(authSessionProvider).refreshToken;

            if (refreshToken == null) {
              throw const GrpcError.unauthenticated('No session found');
            }

            final refreshResult = await ref
                .read(tokenRefresherProvider)
                .refreshTokens(refreshToken);

            switch (refreshResult) {
              case Success(:final value):
                // Awaited so the rotated tokens are persisted before the RPC
                // that needs them goes out.
                await ref
                    .read(sessionControllerProvider)
                    .setAuthTokens(value.accessToken, value.refreshToken);
                token = value.accessToken;
              case Failure():
                throw const GrpcError.unauthenticated('Session expired');
            }
          }

          if (token != null) {
            metadata['Authorization'] = 'Bearer $token';
          }
        },
      ],
    ),
    interceptors: [],
  );
}

CallOptions _timeoutOptions({List<MetadataProvider> providers = const []}) =>
    CallOptions(
      timeout: const Duration(seconds: networkSecondsTimeout),
      providers: providers,
    );
