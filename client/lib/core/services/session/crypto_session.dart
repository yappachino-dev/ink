import 'package:drift/drift.dart';

import 'package:ink/core/services/session/session_exceptions.dart';

abstract interface class CryptoSession {
  /// Whether a key is currently loaded.
  ///
  /// Callers that can still do useful work without a key — storing ciphertext,
  /// for instance — must ask this rather than probe [masterKey] and catch
  /// [SessionLockedException]. Using an exception to ask a yes/no
  /// question turns ordinary control flow into error handling, and hides the
  /// real intent.
  bool get hasKey;

  /// The loaded key, or throws [SessionLockedException] when [hasKey] is false.
  Uint8List get masterKey;
}
