import 'package:flutter_test/flutter_test.dart';
import 'package:ink/core/domain/result.dart';
import 'package:ink/core/infrastructure/crypto/crypto.dart';
import 'package:ink/core/services/session/session_controller.dart';
import 'package:ink/features/vault/data/secure_vault_service.dart';
import 'package:ink/features/vault/domain/entities/key_slot.dart';
import 'package:ink/features/vault/domain/entities/key_type.dart';
import 'package:ink/features/vault/domain/failures/vault_failure.dart';
import 'package:ink/features/vault/domain/vault_repository.dart';
import 'package:ink/features/vault/domain/vault_service.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';

import '../../../fixtures/vault_fixtures.dart';
import '../../../helpers/test_helpers.dart';

class MockRandomService extends Mock implements RandomService {}

class MockDerivationService extends Mock implements DerivationService {}

class MockEncryptionService extends Mock implements EncryptionService {}

class MockSessionController extends Mock implements SessionController {}

class MockVaultRepository extends Mock implements VaultRepository {}

void main() {
  setUpAll(() {
    Logger.level = Level.off;
    registerTestFallbacks();
  });

  late MockRandomService mockRandom;
  late MockDerivationService mockDerivation;
  late MockEncryptionService mockEncryption;
  late MockVaultRepository mockRepo;
  late MockSessionController mockSessionController;
  late VaultService service;

  setUp(() {
    mockRandom = MockRandomService();
    mockDerivation = MockDerivationService();
    mockEncryption = MockEncryptionService();
    mockSessionController = MockSessionController();
    mockRepo = MockVaultRepository();

    service = SecureVaultService(
      random: mockRandom,
      derivation: mockDerivation,
      encryption: mockEncryption,
      sessionController: mockSessionController,
      repository: mockRepo,
    );
  });

  final masterKey = VaultFixtures.defaultMasterKey;

  final pinSlot = VaultFixtures.buildKeySlot();

  group('SecureVaultService - intializeNewVault', () {
    test(
      'saves all provided secrets to repository and sets session mk',
      () async {
        when(() => mockRandom.generateBytes(any())).thenReturn(masterKey);
        when(
          () => mockDerivation.derive(any(), any()),
        ).thenAnswer((_) async => masterKey);
        when(
          () => mockEncryption.encrypt(any(), any()),
        ).thenAnswer((_) async => masterKey);
        when(() => mockSessionController.setMasterKey(any())).thenReturn(null);
        when(() => mockRepo.saveKeySlots(any())).thenAnswer((_) async {
          return const Success(null);
        });

        const secrets = {KeyType.pin: '1234', KeyType.pattern: '4321'};
        await service.intializeNewVault(secrets);

        final captured = verify(
          () => mockRepo.saveKeySlots(captureAny()),
        ).captured;
        final savedSlots = captured.first as List<KeySlot>;

        expect(savedSlots.length, 2);
        expect(savedSlots.any((slot) => slot.type == KeyType.pin), isTrue);
        expect(savedSlots.any((slot) => slot.type == KeyType.pattern), isTrue);

        verify(() => mockSessionController.setMasterKey(masterKey)).called(1);
      },
    );
  });

  group('SecureVaultService - unlock', () {
    test(
      'returns VaultNotInitialized failure when the slot is missing',
      () async {
        when(
          () => mockRepo.getKeySlotByType(KeyType.pin),
        ).thenAnswer((_) async => const Success(null));

        final result = await service.unlock(KeyType.pin, '1234');

        expect(
          result,
          const Failure<void, VaultFailure>(VaultNotInitialized()),
        );

        verifyNever(() => mockSessionController.setMasterKey(any()));
      },
    );

    test(
      'stores master key in session and succeeds for a valid secret',
      () async {
        when(
          () => mockRepo.getKeySlotByType(KeyType.pin),
        ).thenAnswer((_) async => Success(pinSlot));
        when(
          () => mockDerivation.derive(any(), any()),
        ).thenAnswer((_) async => masterKey);
        when(
          () => mockEncryption.decrypt(any(), any()),
        ).thenAnswer((_) async => masterKey);
        when(
          () => mockRepo.syncKeys(),
        ).thenAnswer((_) async => const Success(null));

        final result = await service.unlock(KeyType.pin, '1234');

        expect(result, isA<Success<void, VaultFailure>>());

        verify(() => mockSessionController.setMasterKey(masterKey)).called(1);
      },
    );

    test(
      'returns Failure(VaultFailure.invalidSecret()) if decryption fails',
      () async {
        when(
          () => mockRepo.getKeySlotByType(KeyType.pin),
        ).thenAnswer((_) async => Success(pinSlot));
        when(
          () => mockDerivation.derive(any(), any()),
        ).thenAnswer((_) async => masterKey);

        when(
          () => mockEncryption.decrypt(any(), any()),
        ).thenThrow(CryptoDecryptionException());

        final result = await service.unlock(KeyType.pin, 'bad_pin');

        expect(
          result,
          const Failure<Never, VaultFailure>(InvalidSecret()),
        );

        verifyNever(() => mockSessionController.setMasterKey(any()));
      },
    );
  });
}
