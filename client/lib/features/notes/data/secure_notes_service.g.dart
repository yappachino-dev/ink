// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'secure_notes_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(secureNotesService)
final secureNotesServiceProvider = SecureNotesServiceProvider._();

final class SecureNotesServiceProvider
    extends $FunctionalProvider<NotesService, NotesService, NotesService>
    with $Provider<NotesService> {
  SecureNotesServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'secureNotesServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$secureNotesServiceHash();

  @$internal
  @override
  $ProviderElement<NotesService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NotesService create(Ref ref) {
    return secureNotesService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotesService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotesService>(value),
    );
  }
}

String _$secureNotesServiceHash() =>
    r'acb5c40bc8c4bbaa14d12cee86fcc5f6c47a1136';
