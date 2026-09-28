import 'dart:typed_data';

import 'package:ink/app/database/database.dart';
import 'package:ink/core/config/user_config.dart';
import 'package:ink/features/vault/domain/entities/key_type.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../fixtures/vault_fixtures.dart';

/// A [UserConfig] over mocked storage, for tests that touch the selected
/// notebook.
///
/// The lens writes through to storage so the notebook you opened survives a
/// restart, which makes preferences a dependency of anything that selects one.
/// Overriding at the call site keeps that to one line per test:
///
/// ```dart
/// userPreferencesProvider.overrideWithValue(await mockUserConfig())
/// ```
Future<UserConfig> mockUserConfig({
  Map<String, Object> values = const {},
}) async {
  SharedPreferences.setMockInitialValues(values);
  return UserConfig(await SharedPreferences.getInstance());
}

void registerTestFallbacks() {
  registerFallbackValue(KeyType.pin);
  registerFallbackValue(Uint8List(0));
  registerFallbackValue(VaultFixtures.buildKeySlot());
  registerFallbackValue(const KeySlotsCompanion());
  registerFallbackValue(const NotesCompanion());
  registerFallbackValue(const NotebooksCompanion());
  registerFallbackValue(const NoteConflictsCompanion());
}
