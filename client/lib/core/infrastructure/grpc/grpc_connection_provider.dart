import 'package:grpc/grpc.dart';
import 'package:ink/core/infrastructure/auth/jwt_decoder.dart';
import 'package:ink/core/infrastructure/auth/token_refresher.dart';
import 'package:ink/core/infrastructure/grpc/client_channel_provider.dart';
import 'package:ink/core/services/session/session_manager.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'grpc_connection_provider.g.dart';

typedef GrpcConnection = ({
  ClientChannel channel,
  CallOptions options,
  List<ClientInterceptor> interceptors,
});

@Riverpod(keepAlive: true)
GrpcConnection grpcConnection(Ref ref) {
  final channel = ref.watch(clientChannelProvider);

  return (
    channel: channel,
    options: CallOptions(),
    interceptors: [],
  );
}

@Riverpod(keepAlive: true)
GrpcConnection grpcAuthConnection(Ref ref) {
  final channel = ref.watch(clientChannelProvider);

  return (
    channel: channel,
    options: CallOptions(
      providers: [
        (metadata, uri) async {
          var token = ref.read(authSessionProvider).accessToken;

          if (token != null && token.isJwtExpired()) {
            final refreshResult = await ref
                .read(tokenRefresherProvider)
                .refreshToken();

            token = refreshResult.fold(
              (tokens) {
                ref
                    .read(sessionControllerProvider)
                    .setAuthTokens(tokens.accessToken, tokens.refreshToken);
                return tokens.accessToken;
              },
              (failure) {
                throw const GrpcError.unauthenticated(
                  'Session expired.',
                );
              },
            );
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
