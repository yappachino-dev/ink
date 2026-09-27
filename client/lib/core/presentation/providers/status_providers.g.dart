// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'status_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the device currently has no usable connection.
///
/// Presentation layers may not import `core/infrastructure` directly, so the
/// connectivity stream is adapted here rather than watched from a widget.

@ProviderFor(isOffline)
final isOfflineProvider = IsOfflineProvider._();

/// Whether the device currently has no usable connection.
///
/// Presentation layers may not import `core/infrastructure` directly, so the
/// connectivity stream is adapted here rather than watched from a widget.

final class IsOfflineProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether the device currently has no usable connection.
  ///
  /// Presentation layers may not import `core/infrastructure` directly, so the
  /// connectivity stream is adapted here rather than watched from a widget.
  IsOfflineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isOfflineProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isOfflineHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isOffline(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isOfflineHash() => r'0b611fb122490edad5bcf8c097c5561f95f5e4ca';

@ProviderFor(syncActivity)
final syncActivityProvider = SyncActivityProvider._();

final class SyncActivityProvider
    extends $FunctionalProvider<SyncActivity, SyncActivity, SyncActivity>
    with $Provider<SyncActivity> {
  SyncActivityProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncActivityProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncActivityHash();

  @$internal
  @override
  $ProviderElement<SyncActivity> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SyncActivity create(Ref ref) {
    return syncActivity(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncActivity value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncActivity>(value),
    );
  }
}

String _$syncActivityHash() => r'aa7c4ca56f8674e82942d734db70fbed9cf41e75';
