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

String _$authNotifierHash() => r'b038d39b9013ec9a18d78b75df94e075c51f6f87';

abstract class _$AuthNotifier extends $Notifier<AuthData> {
  AuthData build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AuthData, AuthData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AuthData, AuthData>,
              AuthData,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
