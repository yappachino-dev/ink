import 'package:dio/dio.dart';
import 'package:ink/core/infrastructure/api/api_endpoints.dart' as endpoints;
import 'package:ink/core/infrastructure/api/dio_provider.dart';
import 'package:ink/features/auth/data/dto/auth_response_dto.dart';
import 'package:ink/features/auth/data/dto/login_request_dto.dart';
import 'package:ink/features/auth/data/dto/register_request_dto.dart';
import 'package:ink/features/auth/data/dto/request_verification_dto.dart';
import 'package:retrofit/retrofit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_remote_data_source.g.dart';

@RestApi()
abstract class AuthRemoteDataSource {
  factory AuthRemoteDataSource(Dio dio) = _AuthRemoteDataSource;

  @POST(endpoints.login)
  Future<AuthResponseDto> login(@Body() LoginRequestDto request);

  @POST(endpoints.requestVerification)
  Future<void> requestVerification(@Body() RequestVerificationDto request);

  @POST(endpoints.register)
  Future<AuthResponseDto> register(@Body() RegisterRequestDto request);

  @POST(endpoints.refresh)
  Future<AuthResponseDto> refresh();
}

@Riverpod(keepAlive: true)
AuthRemoteDataSource authRemoteDataSource(Ref ref) =>
    AuthRemoteDataSource(ref.watch(refreshDioProvider));
