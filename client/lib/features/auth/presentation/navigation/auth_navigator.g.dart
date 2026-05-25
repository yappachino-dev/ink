// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_navigator.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(authNavigator)
final authNavigatorProvider = AuthNavigatorProvider._();

final class AuthNavigatorProvider
    extends $FunctionalProvider<AuthNavigator, AuthNavigator, AuthNavigator>
    with $Provider<AuthNavigator> {
  AuthNavigatorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authNavigatorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authNavigatorHash();

  @$internal
  @override
  $ProviderElement<AuthNavigator> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthNavigator create(Ref ref) {
    return authNavigator(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthNavigator value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthNavigator>(value),
    );
  }
}

String _$authNavigatorHash() => r'79c8843d8358452062a27b39407a33ac38b7a709';
