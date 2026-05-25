const String apiUrl = String.fromEnvironment('API_BASE_URL');

const String environmentName = String.fromEnvironment(
  'ENV_NAME',
  defaultValue: 'development',
);

const int networkSecondsTimeout = int.fromEnvironment(
  'NETWORK_SECONDS_TIMEOUT',
  defaultValue: 15,
);
