import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:ink/core/config/app_config_provider.dart';
import 'package:ink/core/infrastructure/api/interceptors/auth_interceptor.dart';
import 'package:ink/core/infrastructure/api/token_refresher.dart';
import 'package:ink/core/infrastructure/storage/cookie_jar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dio_provider.g.dart';

@Riverpod(keepAlive: true)
TokenRefresher tokenRefresher(Ref ref) =>
    throw UnimplementedError('tokenRefresher must be overriden in main');

@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  final config = ref.read(appConfigProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: config.apiUrl,
      connectTimeout: config.networkTimeout,
      receiveTimeout: config.networkTimeout,
      sendTimeout: config.networkTimeout,
      contentType: Headers.jsonContentType,
    ),
  );

  dio.interceptors.addAll([
    CookieManager(ref.watch(cookieJarProvider)),
    AuthInterceptor(ref),
    if (kDebugMode) LogInterceptor(requestBody: true, responseBody: true),
  ]);

  return dio;
}

@Riverpod(keepAlive: true)
Dio refreshDio(Ref ref) {
  final config = ref.read(appConfigProvider);

  final refreshDio = Dio(
    BaseOptions(
      baseUrl: config.apiUrl,
      connectTimeout: config.networkTimeout,
      receiveTimeout: config.networkTimeout,
      sendTimeout: config.networkTimeout,
      contentType: Headers.jsonContentType,
    ),
  );

  refreshDio.interceptors.add(CookieManager(ref.watch(cookieJarProvider)));

  return refreshDio;
}
