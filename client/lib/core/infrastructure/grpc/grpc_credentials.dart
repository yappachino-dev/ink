import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as crypto;
import 'package:grpc/grpc.dart' as grpc;
// gRPC does not publicly export its channel implementation required to bridge
// a custom transport connector.
// ignore_for_file: implementation_imports
import 'package:grpc/src/client/channel.dart' as grpc_internal;
import 'package:grpc/src/client/http2_connection.dart'
    as grpc_internal_connection;
import 'package:http2/transport.dart';
import 'package:ink/core/infrastructure/logger.dart';
import 'package:pointycastle/asn1.dart';

const _pinPrefix = 'sha256/';

final class GrpcTlsSettings {
  const GrpcTlsSettings({
    required this.credentials,
    required this.pinConfigured,
    required this.spkiPins,
    required this.pinError,
    this.trustedCertificateBytes,
  });

  final grpc.ChannelCredentials credentials;
  final bool pinConfigured;
  final Set<String>? spkiPins;
  final String? pinError;
  final List<int>? trustedCertificateBytes;
}

GrpcTlsSettings grpcChannelCredentials({
  required String environment,
  required bool isReleaseMode,
  String certificatePin = '',
  List<int>? trustedCertificateBytes,
}) {
  final allowInsecure = !isReleaseMode && environment == 'development';
  if (allowInsecure) {
    return const GrpcTlsSettings(
      credentials: grpc.ChannelCredentials.insecure(),
      pinConfigured: false,
      spkiPins: null,
      pinError: null,
    );
  }

  if (certificatePin.isEmpty) {
    return GrpcTlsSettings(
      credentials: trustedCertificateBytes == null
          ? const grpc.ChannelCredentials.secure()
          : grpc.ChannelCredentials.secure(
              certificates: trustedCertificateBytes,
            ),
      pinConfigured: false,
      spkiPins: null,
      pinError: null,
    );
  }

  final pins = parseCertificatePins(certificatePin);
  if (pins == null) {
    const message =
        'Invalid GRPC_CERT_PIN; expected comma-separated sha256/<base64> SPKI pins';
    logger.e(message);
    return GrpcTlsSettings(
      credentials: trustedCertificateBytes == null
          ? const grpc.ChannelCredentials.secure()
          : grpc.ChannelCredentials.secure(
              certificates: trustedCertificateBytes,
            ),
      pinConfigured: true,
      spkiPins: null,
      pinError: message,
    );
  }

  return GrpcTlsSettings(
    credentials: const grpc.ChannelCredentials.secure(),
    pinConfigured: true,
    spkiPins: pins,
    pinError: null,
  );
}

Set<String>? parseCertificatePins(String value) {
  final pins = value
      .split(',')
      .map((pin) => pin.trim())
      .where((pin) => pin.isNotEmpty)
      .toSet();
  if (pins.isEmpty || pins.any((pin) => !_isValidPin(pin))) {
    return null;
  }
  return pins.map((pin) => pin.substring(_pinPrefix.length)).toSet();
}

bool isPinnedSpki(X509Certificate certificate, Set<String> expectedPins) {
  try {
    final spki = subjectPublicKeyInfoDer(certificate.der);
    final fingerprint = base64.encode(crypto.sha256.convert(spki).bytes);
    return expectedPins.contains(fingerprint);
  } on Object catch (error) {
    logger.w('Unable to extract certificate SPKI for pinning: $error');
    return false;
  }
}

/// Extracts the exact DER-encoded SubjectPublicKeyInfo from an X.509
/// certificate without reconstructing it, preserving standard pin semantics.
Uint8List subjectPublicKeyInfoDer(Uint8List certificateDer) {
  final certificate = ASN1Sequence.fromBytes(certificateDer);
  if (certificate.elements == null || certificate.elements!.length != 3) {
    throw const FormatException('Invalid X.509 certificate structure');
  }
  final tbsCertificate = certificate.elements![0];
  if (tbsCertificate is! ASN1Sequence || tbsCertificate.elements == null) {
    throw const FormatException('Invalid X.509 tbsCertificate');
  }
  final elements = tbsCertificate.elements!;
  final versionOffset = elements.first.tag == 0xa0 ? 1 : 0;
  final subjectPublicKeyInfoIndex = versionOffset + 5;
  if (elements.length <= subjectPublicKeyInfoIndex) {
    throw const FormatException('Missing SubjectPublicKeyInfo');
  }
  final spki = elements[subjectPublicKeyInfoIndex];
  if (spki is! ASN1Sequence) {
    throw const FormatException('Invalid SubjectPublicKeyInfo');
  }
  return spki.encode();
}

bool _isValidPin(String pin) {
  if (!pin.startsWith(_pinPrefix)) {
    return false;
  }
  final encoded = pin.substring(_pinPrefix.length);
  if (encoded.isEmpty) {
    return false;
  }
  try {
    return base64.decode(encoded).length == 32;
  } on FormatException {
    return false;
  }
}

final class PinnedGrpcTransportConnector extends grpc.ClientTransportConnector {
  PinnedGrpcTransportConnector({
    required this.host,
    required this.port,
    required this.expectedPins,
    required this.pinError,
    this.trustedCertificateBytes,
  });

  final String host;
  final int port;
  final Set<String>? expectedPins;
  final String? pinError;
  final List<int>? trustedCertificateBytes;

  Socket? _socket;
  final _done = Completer<void>();

  @override
  Future<void> get done => _done.future;

  @override
  Future<ClientTransportConnection> connect() async {
    if (pinError != null || expectedPins == null || expectedPins!.isEmpty) {
      throw const HandshakeException(
        'gRPC certificate pinning is configured but invalid',
      );
    }

    SecureSocket? socket;
    try {
      final context = SecurityContext(withTrustedRoots: true)
        ..setAlpnProtocols(grpc.supportedAlpnProtocols, false);
      if (trustedCertificateBytes != null) {
        context.setTrustedCertificatesBytes(trustedCertificateBytes!);
      }
      final rawSocket = await Socket.connect(host, port);
      socket = await SecureSocket.secure(
        rawSocket,
        host: host,
        context: context,
        onBadCertificate: (_) => false,
      );
      final certificate = socket.peerCertificate;
      if (certificate == null || !isPinnedSpki(certificate, expectedPins!)) {
        throw const HandshakeException(
          'gRPC server certificate SPKI does not match any configured pin',
        );
      }
      _socket = socket;
      return ClientTransportConnection.viaSocket(socket);
    } on HandshakeException {
      socket?.destroy();
      rethrow;
    } on Object {
      socket?.destroy();
      throw const HandshakeException('gRPC TLS handshake failed');
    }
  }

  @override
  String get authority => '$host:$port';

  @override
  void shutdown() {
    _socket?.destroy();
    if (!_done.isCompleted) {
      _done.complete();
    }
  }
}

final class PinnedGrpcClientChannel extends grpc_internal.ClientChannelBase {
  PinnedGrpcClientChannel({
    required this.host,
    required this.port,
    required this.expectedPins,
    required this.pinError,
    this.trustedCertificateBytes,
  });

  final String host;
  final int port;
  final Set<String>? expectedPins;
  final String? pinError;
  final List<int>? trustedCertificateBytes;

  @override
  grpc_internal_connection.Http2ClientConnection createConnection() =>
      grpc_internal_connection
          .Http2ClientConnection.fromClientTransportConnector(
        PinnedGrpcTransportConnector(
          host: host,
          port: port,
          expectedPins: expectedPins,
          pinError: pinError,
          trustedCertificateBytes: trustedCertificateBytes,
        ),
        const grpc.ChannelOptions(),
      );
}
