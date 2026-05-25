import 'package:flutter_test/flutter_test.dart';
import 'package:ink/core/infrastructure/crypto/random.dart';

void main() {
  final randomService = SecureRandomService();

  group('RandomService', () {
    test('generates requested length', () {
      final salt = randomService.generateBytes(16);
      expect(salt.length, 16);
    });

    test('multiple calls generate different generate', () {
      final nonce1 = randomService.generateBytes(16);
      final nonce2 = randomService.generateBytes(16);

      expect(nonce1, isNot(equals(nonce2)));
    });
  });
}
