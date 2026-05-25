sealed class CoreFailure {
  const CoreFailure();
}

class NetworkFailure extends CoreFailure {
  const NetworkFailure();
}

class ApiFailure extends CoreFailure {
  const ApiFailure(this.statusCode, this.message);

  final int statusCode;
  final String? message;
}

class StorageFailure extends CoreFailure {
  const StorageFailure(this.message);

  final String message;
}

class CryptoFailure extends CoreFailure {
  const CryptoFailure(this.message);

  final String message;
}

class UnexpectedFailure extends CoreFailure {
  const UnexpectedFailure(this.e);

  final Object e;
}
