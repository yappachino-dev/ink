import 'package:ink/core/infrastructure/crypto/derivation.dart';
import 'package:ink/core/infrastructure/crypto/encryption.dart';
import 'package:ink/core/infrastructure/crypto/random.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'crypto_providers.g.dart';

@Riverpod(keepAlive: true)
EncryptionService encryptionService(Ref ref) => AesGcmService();

@Riverpod(keepAlive: true)
DerivationService derivationService(Ref ref) => Argon2Service();

@Riverpod(keepAlive: true)
RandomService randomService(Ref ref) => SecureRandomService();
