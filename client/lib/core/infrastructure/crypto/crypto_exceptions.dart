sealed class CryptoException implements Exception {
  const CryptoException(this.message);

  final String message;

  @override
  String toString() => message;
}

class CryptoDerivationException implements Exception {
  CryptoDerivationException([this.message = 'Key derivation failed']);

  final String message;
}

class CryptoEncryptionException implements Exception {
  CryptoEncryptionException([this.message = 'Encryption operation failed']);

  final String message;
}

class CryptoDecryptionException implements Exception {
  CryptoDecryptionException([
    this.message = 'Authentication failed or data corrupted',
  ]);

  final String message;
}

class CryptoUnknownException implements Exception {
  CryptoUnknownException([
    this.message = 'An unknown cryptographic error occurred',
  ]);

  final String message;
}
