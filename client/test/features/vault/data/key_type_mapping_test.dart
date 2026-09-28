import 'package:flutter_test/flutter_test.dart';
import 'package:ink/core/infrastructure/grpc/gen/vault/v1/vault.pb.dart' as pb;
import 'package:ink/features/vault/data/mappers/key_slot_remote_mapper.dart';
import 'package:ink/features/vault/domain/entities/key_type.dart';

// The server persists key_type as the raw proto enum int with no compile-time
// linkage to either side. These tests pin the numeric contract so a reordering
// in the .proto or a mapper drift fails loudly here instead of corrupting
// stored slots.
void main() {
  group('KeyType mapping (proto <-> domain)', () {
    test('proto enum values match the persisted integer contract', () {
      // Mirrors proto/vault/v1/*.proto — the DB stores these numbers.
      expect(pb.KeyType.KEY_TYPE_UNSPECIFIED.value, 0);
      expect(pb.KeyType.KEY_TYPE_PIN.value, 1);
      expect(pb.KeyType.KEY_TYPE_PATTERN.value, 2);
      expect(pb.KeyType.KEY_TYPE_RECOVERY.value, 3);
    });

    test('every known proto value maps to its domain counterpart', () {
      expect(pb.KeyType.KEY_TYPE_PIN.toDomain(), KeyType.pin);
      expect(pb.KeyType.KEY_TYPE_PATTERN.toDomain(), KeyType.pattern);
      expect(pb.KeyType.KEY_TYPE_RECOVERY.toDomain(), KeyType.recoveryPhrase);
    });

    test('unknown proto values degrade to KeyType.unknown', () {
      expect(pb.KeyType.KEY_TYPE_UNSPECIFIED.toDomain(), KeyType.unknown);
      // Ints outside the known set resolve to null; the mapper's default
      // branch guards against such values arriving from newer servers.
      expect(pb.KeyType.valueOf(99), isNull);
    });

    test('every domain value round-trips through proto', () {
      for (final type in KeyType.values.where((t) => t != KeyType.unknown)) {
        expect(type.toProto().toDomain(), type);
      }
    });

    test('unknown domain value maps to KEY_TYPE_UNSPECIFIED', () {
      expect(KeyType.unknown.toProto(), pb.KeyType.KEY_TYPE_UNSPECIFIED);
    });
  });
}
