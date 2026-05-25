import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:ink/core/infrastructure/crypto/crypto.dart';

void main() {
  final encryptionService = AesGcmService();

  group('EncryptionService', () {
    const note = 'Hello, world';
    final data = Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8]);
    final key = Uint8List.fromList(List.generate(32, (idx) => idx));

    test('encrypt is random each time', () async {
      final out1 = await encryptionService.encrypt(data, key);
      final out2 = await encryptionService.encrypt(data, key);

      expect(out1, isNot(equals(out2)));
    });

    test('encrypts and decrypts back to original data', () async {
      final encryptedData = await encryptionService.encrypt(data, key);

      expect(encryptedData, isNot(equals(data)));

      final decryptedData = await encryptionService.decrypt(encryptedData, key);

      expect(decryptedData, equals(data));
    });

    test('encrypts and decrypts string back to original data', () async {
      final encryptedData = await encryptionService.encryptString(note, key);

      expect(encryptedData, isNot(equals(note)));

      final decryptedData = await encryptionService.decryptString(
        encryptedData,
        key,
      );

      expect(decryptedData, equals(note));
    });

    test('decrypting with wrong key fails', () async {
      final encryptedData = await encryptionService.encrypt(data, key);

      final badKey = Uint8List.fromList(key);
      badKey[0] = 99;

      expect(
        () => encryptionService.decrypt(encryptedData, badKey),
        throwsA(isA<CryptoDecryptionException>()),
      );
    });

    test('decrypting tampered blob fails', () async {
      final encrypted = await encryptionService.encrypt(data, key);

      final tampered = Uint8List.fromList(encrypted);
      tampered[0] ^= 0x01;

      expect(
        () => encryptionService.decrypt(tampered, key),
        throwsA(isA<CryptoDecryptionException>()),
      );
    });
  });
}
