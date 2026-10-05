import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/app/database/adapters/notebooks_local_data_source.dart';
import 'package:ink/app/database/adapters/notes_local_data_source.dart';
import 'package:ink/app/database/adapters/vault_local_data_source.dart';
import 'package:ink/app/database/database.dart';
import 'package:ink/app/database/database_provider.dart';
import 'package:ink/app/navigation/navigators/overrides.dart';
import 'package:ink/core/config/user_config.dart';
import 'package:ink/core/domain/sync_events.dart';
import 'package:ink/core/infrastructure/auth/token_refresher.dart';
import 'package:ink/core/infrastructure/crypto/crypto.dart';
import 'package:ink/core/infrastructure/storage/shared_prefs.dart';
import 'package:ink/core/services/session/session_controller.dart';
import 'package:ink/core/services/session/session_manager.dart';
import 'package:ink/core/services/session/session_state.dart';
import 'package:ink/core/services/sync/sync_orchestrator.dart';
import 'package:ink/core/services/sync/sync_state.dart';
import 'package:ink/core/services/sync/sync_storage.dart';
import 'package:ink/features/auth/data/auth_service_impl.dart';
import 'package:ink/features/auth/data/unified_auth_repository.dart';
import 'package:ink/features/auth/domain/auth_preferences.dart';
import 'package:ink/features/auth/domain/auth_providers.dart';
import 'package:ink/features/notes/data/note_decryptor.dart';
import 'package:ink/features/notes/data/notebooks_sync_delegate.dart';
import 'package:ink/features/notes/data/notes_sync_delegate.dart';
import 'package:ink/features/notes/data/remote_note_metadata_enricher.dart';
import 'package:ink/features/notes/data/secure_notes_service.dart';
import 'package:ink/features/notes/data/sources/notebooks_local_store_provider.dart';
import 'package:ink/features/notes/data/sources/notes_local_store_provider.dart';
import 'package:ink/features/notes/data/unified_notes_repository.dart';
import 'package:ink/features/notes/domain/notes_providers.dart';
import 'package:ink/features/vault/data/secure_vault_service.dart';
import 'package:ink/features/vault/data/sources/vault_local_store_provider.dart';
import 'package:ink/features/vault/domain/vault_providers.dart';
import 'package:ink/features/vault/presentation/notifiers/vault_notifier.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';
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
    authPreferencesProvider.overrideWith(
      (ref) => _AuthPreferencesAdapter(ref, ref.watch(userPreferencesProvider)),
    ),
    notesServiceProvider.overrideWith(
      (ref) => ref.watch(secureNotesServiceProvider),
    ),
    notesLocalStoreProvider.overrideWith(
      (ref) => NotesLocalDataSource(
        notesDao: ref.watch(appDatabaseProvider).notesDao,
      ),
    ),
    notebooksLocalStoreProvider.overrideWith(
      (ref) => NotebooksLocalDataSource(
        notebooksDao: ref.watch(appDatabaseProvider).notebooksDao,
      ),
    ),
    vaultServiceProvider.overrideWith(
      (ref) => ref.watch(secureVaultServiceProvider),
    ),
    vaultRandomServiceProvider.overrideWithValue(_VaultRandomService()),
    vaultSessionStatusProvider.overrideWith(
      (ref) => _VaultSessionStatusAdapter(ref.watch(sessionManagerProvider)),
    ),
    vaultLocalStoreProvider.overrideWith(
      (ref) => VaultLocalDataSource(
        keySlotsDao: ref.watch(appDatabaseProvider).keySlotsDao,
      ),
    ),
    vaultRecoveryProvider.overrideWith(
      (ref) => _VaultRecoveryAdapter(
        ref,
        database: ref.watch(appDatabaseProvider),
        session: ref.watch(sessionControllerProvider),
        syncStorage: ref.watch(syncStorageProvider),
      ),
    ),
    syncControllerProvider.overrideWith(
      (ref) =>
          _SyncControllerAdapter(ref.watch(syncOrchestratorProvider.notifier)),
    ),
    syncEventsProvider.overrideWith((ref) {
      // Sync events are edge-triggered invalidations, not a replayable log.
      // Notifiers fetch current data when they build, so replaying an old
      // success would only cause redundant refreshes.
      final events = StreamController<SyncEvent>.broadcast();
      ref
        ..listen(syncOrchestratorProvider, (previous, next) {
          if (next is SyncSuccess) events.add(SyncEvent.completed);
        })
        ..onDispose(events.close);
      return events.stream;
    }),
    registeredSyncablesProvider.overrideWith((ref) {
      final concreteNotesRepo = ref.watch(unifiedNotesRepositoryProvider);

      // Sync applies carry ciphertext only, so the derived-metadata cache has
      // to be filled on this side of the repository. Without it, synced notes
      // land with an empty title preview and no filterable day, and every
      // list filter silently misses them.
      final notesEngine = RemoteNoteMetadataEnricher(
        inner: concreteNotesRepo,
        cryptoSession: ref.watch(cryptoSessionProvider),
        decryptor: NoteDecryptor(ref.watch(encryptionServiceProvider)),
      );

      return [
        NotebooksSyncDelegate(engine: concreteNotesRepo),
        NotesSyncDelegate(engine: notesEngine),
      ];
    }),
    ...overrideNavigators(),
  ];
}

class _VaultRandomService implements VaultRandomService {
  final _random = SecureRandomService();

  @override
  Uint8List generateBytes(int length) => _random.generateBytes(length);
}

class _AuthPreferencesAdapter implements AuthPreferences {
  const _AuthPreferencesAdapter(this._ref, this._config);

  final Ref _ref;
  final UserConfig _config;

  @override
  bool get localOnly => _config.localOnly;

  @override
  Future<void> setLocalOnly({required bool local}) async {
    await _config.setLocalOnly(local: local);
    // UserConfig is a synchronous wrapper over SharedPreferences, so writing a
    // value notifies nobody. Anything already watching `localOnly` - the sync
    // trust row, the profile registration entry - kept rendering the value from
    // before the write. AppShell holds its branches in an IndexedStack, so
    // Profile was not rebuilt on the tab switch either and the row stayed live.
    _ref.invalidate(userPreferencesProvider);
  }
}

class _VaultSessionStatusAdapter implements VaultSessionStatus {
  const _VaultSessionStatusAdapter(this._state);

  final SessionState _state;

  @override
  bool get isLoaded => _state.isLoaded;

  @override
  bool get hasLoadError => _state.loadError != null;

  @override
  bool get hasAccessToken => _state.accessToken != null;

  @override
  bool get hasMasterKey => _state.masterKey != null;
}

class _VaultRecoveryAdapter implements VaultRecovery {
  const _VaultRecoveryAdapter(
    this._ref, {
    required AppDatabase database,
    required SessionController session,
    required SyncStorage syncStorage,
  }) : _database = database,
       _session = session,
       _syncStorage = syncStorage;

  final Ref _ref;
  final AppDatabase _database;
  final SessionController _session;
  final SyncStorage _syncStorage;

  @override
  Future<void> reset() async {
    await _database.resetDatabase();
    await _syncStorage.saveSyncCursor(0);
    // Awaited: returning before the clears land would leave the access token
    // readable by a restarted process, making the app look still signed in.
    await _session.clearAccessToken();
    await _session.clearRefreshToken();
    // Dropping the key slots does not by itself move the vault out of its
    // unlocked state, and AppShell holds its branches in an IndexedStack, so
    // nothing rebuilds on its own. Without this the app keeps believing it
    // has a vault, and the next read hits a dropped table.
    _ref.invalidate(vaultProvider);
  }
}

class _SyncControllerAdapter implements SyncController {
  const _SyncControllerAdapter(this._orchestrator);

  final SyncOrchestrator _orchestrator;

  @override
  Future<void> performSync() => _orchestrator.performSync();
}

Widget wrapWithTranslation({required Widget child}) {
  return TranslationProvider(child: child);
}
