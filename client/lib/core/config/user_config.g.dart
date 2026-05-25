// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_config.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(userPreferences)
final userPreferencesProvider = UserPreferencesProvider._();

final class UserPreferencesProvider
    extends $FunctionalProvider<UserConfig, UserConfig, UserConfig>
    with $Provider<UserConfig> {
  UserPreferencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userPreferencesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userPreferencesHash();

  @$internal
  @override
  $ProviderElement<UserConfig> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UserConfig create(Ref ref) {
    return userPreferences(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserConfig value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserConfig>(value),
    );
  }
}

String _$userPreferencesHash() => r'6138bdfbfe05686b0b84bddf9c6fdd6e974b6d9c';
