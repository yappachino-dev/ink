import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:ink/core/infrastructure/crypto/derivation.dart';

void main() {
  final derivationService = Argon2Service();

  group('derivationService', () {
    const pin = '1234';
    final data = Uint8List.fromList([1, 2, 3, 4]);
    final salt = Uint8List.fromList(List.generate(16, (idx) => idx));

    test('derive provides same output from same input', () async {
      final key1 = await derivationService.derive(data, salt);
      final key2 = await derivationService.derive(data, salt);

      expect(key1, equals(key2));
    });

    test('deriveFromString provides same output from same input', () async {
      final key1 = await derivationService.deriveFromString(pin, salt);
      final key2 = await derivationService.deriveFromString(pin, salt);

      expect(key1, equals(key2));
    });

    test('different salt yields absolutely different key', () async {
      final key1 = await derivationService.derive(data, salt);

      final badSalt = Uint8List.fromList(salt);
      badSalt[0] = 99;

      final key2 = await derivationService.derive(data, badSalt);

      expect(key1, isNot(equals(key2)));
    });

    test('normalized string yeild the same key', () async {
      const string1 = '\u00E9';
      const string2 = 'e\u0301';

      final key1 = await derivationService.deriveFromString(string1, salt);
      final key2 = await derivationService.deriveFromString(string2, salt);

      expect(key1, equals(key2));

      const string3 = '\u212A';
      const string4 = '\u004B';

      final key3 = await derivationService.deriveFromString(string3, salt);
      final key4 = await derivationService.deriveFromString(string4, salt);

      expect(key3, equals(key4));
    });
  });
}
