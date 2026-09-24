import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/features/notes/domain/notes_service.dart';

/// Domain-facing notes service dependency.
///
/// The concrete implementation is wired by the application composition root
/// in `app/init.dart`; presentation code only depends on this contract.
final notesServiceProvider = Provider<NotesService>(
  (ref) => throw StateError(
    'notesServiceProvider must be overridden at the app root',
  ),
);
