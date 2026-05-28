class AppConfig {
  const AppConfig({
    required this.grpcHost,
    required this.grpcPort,
    required this.environment,
    required this.networkTimeout,
  });

  final String grpcHost;
  final int grpcPort;
  final String environment;
  final Duration networkTimeout;
}
