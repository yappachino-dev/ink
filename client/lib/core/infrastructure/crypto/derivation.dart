import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:unorm_dart/unorm_dart.dart' as unorm;

// Used as a contract
// ignore: one_member_abstracts
abstract class DerivationService {
  Future<Uint8List> derive(Uint8List data, Uint8List salt);
}

extension StringDerivation on DerivationService {
  Future<Uint8List> deriveFromString(String text, Uint8List salt) {
    final normalized = unorm.nfc(text);
    final bytes = utf8.encode(normalized);

    return derive(bytes, salt);
  }
}

class Argon2Service implements DerivationService {
  @override
  Future<Uint8List> derive(Uint8List data, Uint8List salt) {
    return compute(_deriveInIsolate, (data, salt));
  }

  static Future<Uint8List> _deriveInIsolate((Uint8List, Uint8List) args) async {
    final data = args.$1;
    final salt = args.$2;

    final algoritm = Argon2id(
      memory: kDebugMode ? 1024 : 65536,
      iterations: kDebugMode ? 1 : 3,
      parallelism: 1,
      hashLength: 32,
    );

    final secretBox = await algoritm.deriveKey(
      secretKey: SecretKeyData(data),
      nonce: salt,
    );

    final bytes = await secretBox.extractBytes();

    return Uint8List.fromList(bytes);
  }
}
