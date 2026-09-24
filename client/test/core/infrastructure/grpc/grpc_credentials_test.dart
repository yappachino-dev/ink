import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as crypto;
import 'package:flutter_test/flutter_test.dart';
import 'package:ink/core/infrastructure/grpc/grpc_credentials.dart';

const _certificatePem = '''
-----BEGIN CERTIFICATE-----
MIIDNjCCAh6gAwIBAgIUe+E1Xth9TMlsYY7qmf9zlfC1Ms0wDQYJKoZIhvcNAQEL
BQAwFDESMBAGA1UEAwwJbG9jYWxob3N0MCAXDTE4MTIzMTIzMDAxMVoYDzIxMTgx
MjA3MjMwMDExWjAUMRIwEAYDVQQDDAlsb2NhbGhvc3QwggEiMA0GCSqGSIb3DQEB
AQUAA4IBDwAwggEKAoIBAQDEEY2eWBX1rTDgsAWheltKiAHREteaqX4iaGwF6/TC
6kMJajZQreySsib+lQ+FTLtMlPWorR5jMfsA6PDocRpK2zOObTqdVqJAiodUi0ov
ds7wgaN7XnUfpPo8NDMA2tV8Bn2mfKWgC3QkUMPCDBkLqiYUuR6j5QJ4Vz2OFV5g
1iR1HzgQgr4pbNjkUJJesr0r1J1a25YbYdLIvzss+aHBTWD+9HYfgWsfJGI3UFgc
zoAJbKSIHYqDGsSKZMgmtixyyEjTDc6OAqjk10jhYdxdglXpTPOWP5YnwWsy8VbU
1ozu93LlWkbbef95FD/XGH/ynglIe1laZwEXdyxOzT3bAgMBAAGjfjB8MB0GA1Ud
DgQWBBS/3CUrYgiD2qwdEDStghi+X3+4pzAfBgNVHSMEGDAWgBS/3CUrYgiD2qwd
EDStghi+X3+4pzAPBgNVHRMBAf8EBTADAQH/MBMGA1UdJQQMMAoGCCsGAQUFBwMB
MBQGA1UdEQQNMAuCCWxvY2FsaG9zdDANBgkqhkiG9w0BAQsFAAOCAQEAu5adpS/h
bWXYaDLW5JGZAiOVVkMDhspJDdPwDHUTqMPj3V6aaecZTc46Q7TLEkLxIjU5OjvR
ZHh3vo9X4S84Yf7NHv8eX50MK/RrzZolUROhZ6gtYZKkdZtjQKQd62ih5EB6gNnZ
+IW9nedg7Sae2Yh22jDC9Tc+dbvroOd7IUwL9gVSCcwiqVjvuWkDa7jqjnRp4sog
yY1Obr14tmUMgR73Db7q3g0cVToztLYIMJnhjiSUs8nk83m/9/O4SGqQmievoZ5N
60OlhU6enfFoj1xKpXWSGv6mqqdX0G9Ehz1EIetFhkBK2pP/R00gf4OMKc4ubw8d
yTSUIeMSOo0QjA==
-----END CERTIFICATE-----
''';

const _spkiPin = 'XJn3msuRp9gR2L/iHrpsXgz5yVQx08hzK3L2+tKOafI=';

void main() {
  late Uint8List certificateDer;
  late X509Certificate certificate;

  setUpAll(() {
    certificateDer = Uint8List.fromList(
      base64.decode(
        _certificatePem
            .replaceAll(RegExp('-----[^-]+-----'), '')
            .replaceAll(RegExp(r'\s'), ''),
      ),
    );
    certificate = _Certificate(certificateDer);
  });

  group('grpcChannelCredentials', () {
    test('uses insecure transport only for explicit development mode', () {
      final settings = grpcChannelCredentials(
        environment: 'development',
        isReleaseMode: false,
        certificatePin: 'sha256/$_spkiPin',
      );

      expect(settings.credentials.isSecure, isFalse);
      expect(settings.pinConfigured, isFalse);
    });

    test('uses secure transport in release development builds', () {
      final settings = grpcChannelCredentials(
        environment: 'development',
        isReleaseMode: true,
        certificatePin: 'sha256/$_spkiPin',
      );

      expect(settings.credentials.isSecure, isTrue);
      expect(settings.pinConfigured, isTrue);
      expect(settings.pinError, isNull);
    });

    test('uses secure transport without a pin by default', () {
      final settings = grpcChannelCredentials(
        environment: 'production',
        isReleaseMode: true,
      );

      expect(settings.credentials.isSecure, isTrue);
      expect(settings.pinConfigured, isFalse);
      expect(settings.spkiPins, isNull);
    });

    test('accepts PEM custom trust bytes for ChannelCredentials', () {
      final settings = grpcChannelCredentials(
        environment: 'production',
        isReleaseMode: true,
        trustedCertificateBytes: utf8.encode(_certificatePem),
      );

      expect(settings.credentials.securityContext, isNotNull);
      expect(settings.pinConfigured, isFalse);
    });

    test('malformed pins fail closed without throwing during setup', () {
      final settings = grpcChannelCredentials(
        environment: 'production',
        isReleaseMode: true,
        certificatePin: 'not-a-pin',
      );

      expect(settings.credentials.isSecure, isTrue);
      expect(settings.pinConfigured, isTrue);
      expect(settings.pinError, isNotNull);
      expect(settings.spkiPins, isNull);
    });

    test('accepts comma-separated standard SPKI pins', () {
      final settings = grpcChannelCredentials(
        environment: 'production',
        isReleaseMode: true,
        certificatePin:
            'sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=, sha256/$_spkiPin',
      );

      expect(settings.pinError, isNull);
      expect(settings.spkiPins, {
        _spkiPin,
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=',
      });
    });
  });

  group('SPKI pinning', () {
    test('extracts the exact OpenSSL-compatible SPKI from certificate DER', () {
      final spki = subjectPublicKeyInfoDer(certificateDer);
      final fingerprint = base64.encode(crypto.sha256.convert(spki).bytes);

      expect(fingerprint, _spkiPin);
    });

    test('does not hash the entire certificate DER', () {
      final certificateFingerprint = base64.encode(
        crypto.sha256.convert(certificateDer).bytes,
      );

      expect(certificateFingerprint, isNot(_spkiPin));
    });

    test('accepts the configured SPKI and rejects another pin', () {
      const pin = _spkiPin;
      final wrongPin = base64.encode(List<int>.filled(32, 1));

      expect(isPinnedSpki(certificate, {pin}), isTrue);
      expect(isPinnedSpki(certificate, {wrongPin}), isFalse);
    });

    test('rejects malformed certificate DER', () {
      expect(
        () => subjectPublicKeyInfoDer(Uint8List.fromList([1, 2, 3])),
        throwsA(anyOf(isA<FormatException>(), isA<RangeError>())),
      );
    });
  });
}

class _Certificate implements X509Certificate {
  const _Certificate(this.der);

  @override
  final Uint8List der;

  @override
  String get issuer => 'test issuer';

  @override
  String get subject => 'localhost';

  @override
  DateTime get startValidity => DateTime.utc(2018);

  @override
  DateTime get endValidity => DateTime.utc(2121);

  @override
  String get pem => '';

  @override
  Uint8List get sha1 => Uint8List(20);
}
