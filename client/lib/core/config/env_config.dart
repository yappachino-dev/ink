const String grpcHost = String.fromEnvironment('GRPC_HOST');
const int grpcPort = int.fromEnvironment('GRPC_PORT');

const String environmentName = String.fromEnvironment(
  'ENV_NAME',
  defaultValue: 'production',
);

const int networkSecondsTimeout = int.fromEnvironment(
  'NETWORK_SECONDS_TIMEOUT',
  defaultValue: 15,
);

const String grpcCertificatePin = String.fromEnvironment('GRPC_CERT_PIN');
