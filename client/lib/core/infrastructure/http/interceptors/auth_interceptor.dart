import 'package:dio/dio.dart';
import 'package:ink/core/infrastructure/auth/token_refresher.dart';
import 'package:ink/core/infrastructure/http/dio_provider.dart';
import 'package:ink/core/services/session/session_manager.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._ref);

  final Ref _ref;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _ref.read(authSessionProvider).accessToken;

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      final refreshResult = await _ref
          .read(tokenRefresherProvider)
          .refreshToken();

      return refreshResult.fold(
        (token) async {
          _ref.read(sessionControllerProvider).setAuthToken(token);

          final opts = Options(
            method: err.requestOptions.method,
            headers: err.requestOptions.headers,
          );

          opts.headers?['Authorization'] = 'Bearer $token';

          try {
            final retryResponse = await _ref
                .read(refreshDioProvider)
                .request<Map<String, dynamic>>(
                  err.requestOptions.path,
                  options: opts,
                  data: err.requestOptions.data,
                  queryParameters: err.requestOptions.queryParameters,
                );

            return handler.resolve(retryResponse);
          } on DioException catch (retryErr) {
            return handler.reject(retryErr);
          }
        },
        (failure) => handler.reject(err),
      );
    }

    handler.next(err);
  }
}
