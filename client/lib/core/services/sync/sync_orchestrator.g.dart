// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_orchestrator.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(registeredSyncables)
final registeredSyncablesProvider = RegisteredSyncablesProvider._();

final class RegisteredSyncablesProvider
    extends $FunctionalProvider<List<Syncable>, List<Syncable>, List<Syncable>>
    with $Provider<List<Syncable>> {
  RegisteredSyncablesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'registeredSyncablesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$registeredSyncablesHash();

  @$internal
  @override
  $ProviderElement<List<Syncable>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Syncable> create(Ref ref) {
    return registeredSyncables(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Syncable> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Syncable>>(value),
    );
  }
}

String _$registeredSyncablesHash() =>
    r'b114ee13034b186322020448102ea43ffb137b74';

@ProviderFor(SyncOrchestrator)
final syncOrchestratorProvider = SyncOrchestratorProvider._();

final class SyncOrchestratorProvider
    extends $NotifierProvider<SyncOrchestrator, SyncState> {
  SyncOrchestratorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncOrchestratorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncOrchestratorHash();

  @$internal
  @override
  SyncOrchestrator create() => SyncOrchestrator();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncState>(value),
    );
  }
}

String _$syncOrchestratorHash() => r'cc9c70626914f4aeb757738a333d5cec48b56640';

abstract class _$SyncOrchestrator extends $Notifier<SyncState> {
  SyncState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SyncState, SyncState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SyncState, SyncState>,
              SyncState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
