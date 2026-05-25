import 'dart:typed_data';

import 'package:ink/features/vault/domain/entities/key_slot.dart';
import 'package:ink/features/vault/domain/entities/key_type.dart';

class VaultFixtures {
  static Uint8List generateBytes(int length, int fill) =>
      Uint8List.fromList(List.filled(length, fill));

  static Uint8List get defaultMasterKey => generateBytes(32, 1);
  static Uint8List get defaultSalt => generateBytes(16, 2);
  static Uint8List get defaultWmk => generateBytes(32, 3);

  static KeySlot buildKeySlot({
    KeyType? type,
    Uint8List? salt,
    Uint8List? wmk,
    DateTime? updatedAt,
  }) {
    return KeySlot(
      type: type ?? KeyType.pin,
      salt: salt ?? defaultSalt,
      wrappedMasterKey: wmk ?? defaultWmk,
      updatedAt: updatedAt ?? DateTime.now().toUtc(),
    );
  }
}
