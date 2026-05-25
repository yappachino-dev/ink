class AppConfig {
  const AppConfig({
    required this.apiUrl,
    required this.environment,
    required this.networkTimeout,
  });

  final String apiUrl;
  final String environment;
  final Duration networkTimeout;
}
