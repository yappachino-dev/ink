import 'package:ink/core/infrastructure/storage/shared_prefs.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'user_config.g.dart';

class UserConfig {
  UserConfig(this._sharedPrefs);

  final SharedPreferences _sharedPrefs;

  static const _localOnlyKey = 'localOnly';
  static const _themeModeKey = 'themeMode';
  static const _paletteIdKey = 'paletteId';
  static const _localeCodeKey = 'localeCode';
  static const _selectedNotebookKey = 'selectedNotebook';

  bool get localOnly => _sharedPrefs.getBool(_localOnlyKey) ?? true;

  Future<void> setLocalOnly({required bool local}) =>
      _sharedPrefs.setBool(_localOnlyKey, local);

  String? get themeModeString => _sharedPrefs.getString(_themeModeKey);

  Future<void> setThemeModeString(String mode) async =>
      _sharedPrefs.setString(_themeModeKey, mode);

  String? get paletteIdString => _sharedPrefs.getString(_paletteIdKey);

  Future<void> setPaletteIdString(String id) async =>
      _sharedPrefs.setString(_paletteIdKey, id);

  String? get localeCode => _sharedPrefs.getString(_localeCodeKey);

  Future<void> setLocaleCode(String code) async =>
      _sharedPrefs.setString(_localeCodeKey, code);

  /// The notebook last opened, so returning to the app resumes where the user
  /// left off rather than dumping them back on the default list.
  String? get selectedNotebookId =>
      _sharedPrefs.getString(_selectedNotebookKey);

  Future<void> setSelectedNotebookId(String id) async =>
      _sharedPrefs.setString(_selectedNotebookKey, id);
}

@Riverpod(keepAlive: true)
UserConfig userPreferences(Ref ref) =>
    UserConfig(ref.watch(sharedPreferencesProvider));
