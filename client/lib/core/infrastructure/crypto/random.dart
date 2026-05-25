import 'dart:math';
import 'dart:typed_data';

// Used as a contract
// ignore: one_member_abstracts
abstract class RandomService {
  Uint8List generateBytes(int length);
}

class SecureRandomService implements RandomService {
  final Random _random = Random.secure();

  @override
  Uint8List generateBytes(int length) {
    final bytes = Uint8List(length);

    for (var i = 0; i < length; i++) {
      bytes[i] = _random.nextInt(256);
    }

    return bytes;
  }
}
