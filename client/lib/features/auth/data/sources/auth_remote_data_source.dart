import 'package:ink/core/infrastructure/auth/types.dart';
import 'package:ink/core/infrastructure/grpc/gen/auth/v1/auth.pbgrpc.dart';
import 'package:ink/core/infrastructure/grpc/grpc_connection_provider.dart';
import 'package:ink/features/auth/domain/types.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_remote_data_source.g.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource({required AuthServiceClient client}) : _client = client;

  final AuthServiceClient _client;

  Future<TokenPayload> login(LoginPayload payload) async {
    final response = await _client.login(
      LoginRequest(email: payload.email, password: payload.password),
    );

    return (
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );
  }

  Future<TokenPayload> register(RegisterPayload payload) async {
    final response = await _client.register(
      RegisterRequest(
        email: payload.email,
        password: payload.password,
        code: payload.code,
      ),
    );

    return (
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );
  }

  Future<void> requestVerification(VerifyEmailPayload payload) async {
    await _client.verifyEmail(VerifyEmailRequest(email: payload.email));
  }

  Future<TokenPayload> refresh() async {
    final response = await _client.refreshToken(RefreshTokenRequest());

    return (
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );
  }
}

@Riverpod(keepAlive: true)
AuthRemoteDataSource authRemoteDataSource(Ref ref) {
  final connection = ref.watch(grpcConnectionProvider);

  return AuthRemoteDataSource(
    client: AuthServiceClient(
      connection.channel,
      options: connection.options,
      interceptors: connection.interceptors,
    ),
  );
}
