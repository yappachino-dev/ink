import 'package:ink/core/config/app_config.dart';
import 'package:ink/core/config/env_config.dart' as env;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_config_provider.g.dart';

@Riverpod(keepAlive: true)
AppConfig appConfig(Ref ref) => const AppConfig(
  restApiUrl: env.restApiUrl,
  grpcHost: env.grpcHost,
  grpcPort: env.grpcPort,
  environment: env.environmentName,
  networkTimeout: Duration(seconds: env.networkSecondsTimeout),
);
