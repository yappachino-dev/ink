import 'package:ink/core/infrastructure/storage/shared_prefs.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'user_config.g.dart';

class UserConfig {
  UserConfig(this._sharedPrefs);

  final SharedPreferences _sharedPrefs;

  static const _localOnlyKey = 'localOnly';
  static const _themeModeKey = 'themeMode';
  static const _localeCodeKey = 'localeCode';

  bool get localOnly => _sharedPrefs.getBool(_localOnlyKey) ?? true;

  Future<void> setLocalOnly({required bool local}) =>
      _sharedPrefs.setBool(_localOnlyKey, local);

  String? get themeModeString => _sharedPrefs.getString(_themeModeKey);

  Future<void> setThemeModeString(String mode) async =>
      _sharedPrefs.setString(_themeModeKey, mode);

  String? get localeCode => _sharedPrefs.getString(_localeCodeKey);

  Future<void> setLocaleCode(String code) async =>
      _sharedPrefs.setString(_localeCodeKey, code);
}

@Riverpod(keepAlive: true)
UserConfig userPreferences(Ref ref) =>
    UserConfig(ref.watch(sharedPreferencesProvider));
