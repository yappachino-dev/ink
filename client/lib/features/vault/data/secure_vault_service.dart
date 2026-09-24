import 'dart:async';

import 'package:ink/core/domain/core_failure.dart';
import 'package:ink/core/domain/result.dart';
import 'package:ink/core/infrastructure/crypto/crypto.dart';
import 'package:ink/core/infrastructure/logger.dart';
import 'package:ink/core/services/session/session_controller.dart';
import 'package:ink/core/services/session/session_manager.dart';
import 'package:ink/features/vault/data/unified_vault_repository.dart';
import 'package:ink/features/vault/domain/entities/key_slot.dart';
import 'package:ink/features/vault/domain/entities/key_type.dart';
import 'package:ink/features/vault/domain/failures/vault_failure.dart';
import 'package:ink/features/vault/domain/vault_repository.dart';
import 'package:ink/features/vault/domain/vault_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'secure_vault_service.g.dart';

class SecureVaultService implements VaultService {
  SecureVaultService({
    required RandomService random,
    required DerivationService derivation,
    required EncryptionService encryption,
    required SessionController sessionController,
    required VaultRepository repository,
  }) : _random = random,
       _derivation = derivation,
       _encryption = encryption,
       _sessionController = sessionController,
       _repository = repository;

  final RandomService _random;
  final DerivationService _derivation;
  final EncryptionService _encryption;
  final SessionController _sessionController;
  final VaultRepository _repository;

  @override
  Future<Result<void, VaultFailure>> intializeNewVault(
    Map<KeyType, String> initialSecrets,
  ) async {
    return _guard(() async {
      final masterKey = _random.generateBytes(32);

      final slotsToSave = <KeySlot>[];

      for (final entry in initialSecrets.entries) {
        final type = entry.key;
        final secret = entry.value;

        final salt = _random.generateBytes(16);
        final kek = await _derivation.deriveFromString(secret, salt);
        final wmk = await _encryption.encrypt(masterKey, kek);

        slotsToSave.add(
          KeySlot(
            type: type,
            salt: salt,
            wrappedMasterKey: wmk,
            updatedAt: DateTime.now().toUtc(),
          ),
        );
      }

      final saveResult = await _repository.saveKeySlots(slotsToSave);
      if (saveResult case Failure(error: final e)) return Failure(e);

      _sessionController.setMasterKey(masterKey);

      return const Success(null);
    });
  }

  @override
  Future<Result<List<KeyType>, VaultFailure>> getUnlockMethods() async {
    final result = await _repository.getAll();

    return result.map((slots) => slots.map((slot) => slot.type).toList());
  }

  @override
  Future<Result<void, VaultFailure>> unlock(KeyType type, String secret) async {
    return _guard(() async {
      final keySlotResult = await _repository.getKeySlotByType(type);
      if (keySlotResult case Failure(error: final e)) return Failure(e);

      final keySlot = keySlotResult.unwrap;

      if (keySlot == null) {
        return const Failure(VaultNotInitialized());
      }

      final kek = await _derivation.deriveFromString(secret, keySlot.salt);
      final masterKey = await _encryption.decrypt(
        keySlot.wrappedMasterKey,
        kek,
      );

      _sessionController.setMasterKey(masterKey);

      unawaited(_repository.syncKeys());

      return const Success(null);
    });
  }

  @override
  Future<Result<void, VaultFailure>> pullKeys() {
    return _guard(_repository.syncKeys);
  }

  @override
  Future<Result<void, VaultFailure>> pushKeys() {
    return _guard(_repository.syncKeys);
  }

  Future<Result<T, VaultFailure>> _guard<T>(
    Future<Result<T, VaultFailure>> Function() action,
  ) async {
    try {
      return await action();
    } on CryptoDecryptionException catch (_) {
      return const Failure(InvalidSecret());
    } on CryptoException catch (e) {
      return Failure(VaultCoreFailure(CryptoFailure(e.message)));
    } on Exception catch (e, st) {
      logger.e('SecureVaultService operation failed', error: e, stackTrace: st);
      return Failure(VaultCoreFailure(UnexpectedFailure(e)));
    }
  }
}

@Riverpod(keepAlive: true)
VaultService secureVaultService(Ref ref) => SecureVaultService(
  random: ref.watch(randomServiceProvider),
  derivation: ref.watch(derivationServiceProvider),
  encryption: ref.watch(encryptionServiceProvider),
  sessionController: ref.watch(sessionControllerProvider),
  repository: ref.watch(vaultRepositoryProvider),
);
