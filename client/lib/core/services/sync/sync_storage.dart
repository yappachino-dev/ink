import 'package:ink/core/infrastructure/storage/shared_prefs.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'sync_storage.g.dart';

class SyncStorage {
  const SyncStorage(this._prefs);

  final SharedPreferences _prefs;
  static const String _cursorKey = 'global_sync_cursor';

  int? getSyncCursor() => _prefs.getInt(_cursorKey);
  Future<void> saveSyncCursor(int cursor) => _prefs.setInt(_cursorKey, cursor);
}

@Riverpod(keepAlive: true)
SyncStorage syncStorage(Ref ref) =>
    SyncStorage(ref.watch(sharedPreferencesProvider));
