import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/app/navigation/navigators/overrides.dart';
import 'package:ink/core/config/user_config.dart';
import 'package:ink/core/infrastructure/auth/token_refresher.dart';
import 'package:ink/core/infrastructure/crypto/crypto.dart';
import 'package:ink/core/infrastructure/storage/shared_prefs.dart';
import 'package:ink/core/services/sync/sync_orchestrator.dart';
import 'package:ink/features/auth/data/auth_service_impl.dart';
import 'package:ink/features/auth/data/unified_auth_repository.dart';
import 'package:ink/features/auth/domain/auth_providers.dart';
import 'package:ink/features/notes/data/notes_sync_delegate.dart';
import 'package:ink/features/notes/data/projects_sync_delegate.dart';
import 'package:ink/features/notes/data/secure_notes_service.dart';
import 'package:ink/features/notes/data/unified_notes_repository.dart';
import 'package:ink/features/notes/domain/notes_providers.dart';
import 'package:ink/features/vault/data/secure_vault_service.dart';
import 'package:ink/features/vault/domain/vault_providers.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<SharedPreferences> initializeGlobalSettings() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sharedPrefs = await SharedPreferences.getInstance();
  final userConfig = UserConfig(sharedPrefs);

  final savedLocaleCode = userConfig.localeCode;
  if (savedLocaleCode != null) {
    await LocaleSettings.setLocaleRaw(savedLocaleCode);
  } else {
    await LocaleSettings.useDeviceLocale();
  }

  return sharedPrefs;
}

/// Overrides installed at the app root. Must be passed to the [ProviderScope]
/// constructed directly inside `runApp` (see main.dart).
List<Override> buildOverrides(SharedPreferences sharedPrefs) {
  return [
    sharedPreferencesProvider.overrideWithValue(sharedPrefs),
    tokenRefresherProvider.overrideWith(
      (ref) => ref.watch(unifiedAuthRepositoryProvider),
    ),
    authServiceProvider.overrideWith(
      (ref) => ref.watch(authServiceImplProvider),
    ),
    notesServiceProvider.overrideWith(
      (ref) => ref.watch(secureNotesServiceProvider),
    ),
    vaultServiceProvider.overrideWith(
      (ref) => ref.watch(secureVaultServiceProvider),
    ),
    vaultRandomServiceProvider.overrideWithValue(_VaultRandomService()),
    registeredSyncablesProvider.overrideWith(
      (ref) {
        final concreteNotesRepo = ref.watch(unifiedNotesRepositoryProvider);

        return [
          ProjectsSyncDelegate(engine: concreteNotesRepo),
          NotesSyncDelegate(engine: concreteNotesRepo),
        ];
      },
    ),
    ...overrideNavigators(),
  ];
}

class _VaultRandomService implements VaultRandomService {
  final _random = SecureRandomService();

  @override
  Uint8List generateBytes(int length) => _random.generateBytes(length);
}

Widget wrapWithTranslation({required Widget child}) {
  return TranslationProvider(child: child);
}
