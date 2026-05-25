import 'package:cookie_jar/cookie_jar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cookie_jar.g.dart';

@Riverpod(keepAlive: true)
PersistCookieJar cookieJar(Ref ref) =>
    throw UnimplementedError('cookieJar must be overridden in main');
