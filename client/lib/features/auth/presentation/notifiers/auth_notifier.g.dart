// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AuthNotifier)
final authProvider = AuthNotifierProvider._();

final class AuthNotifierProvider
    extends $NotifierProvider<AuthNotifier, AuthData> {
  AuthNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authNotifierHash();

  @$internal
  @override
  AuthNotifier create() => AuthNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthData>(value),
    );
  }
}

String _$authNotifierHash() => r'99d14ffff6022951ff4ac225de4fa91f47941d39';

abstract class _$AuthNotifier extends $Notifier<AuthData> {
  AuthData build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AuthData, AuthData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AuthData, AuthData>,
              AuthData,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
