class AppConfig {
  const AppConfig({
    required this.grpcHost,
    required this.grpcPort,
    required this.environment,
    required this.networkTimeout,
    required this.certificatePin,
  });

  final String grpcHost;
  final int grpcPort;
  final String environment;
  final Duration networkTimeout;
  final String certificatePin;
}
