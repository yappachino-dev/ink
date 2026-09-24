import 'package:ink/features/notes/data/ports/notes_local_store.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notes_local_store_provider.g.dart';

@riverpod
NotesLocalStore notesLocalStore(Ref ref) => throw StateError(
  'notesLocalStoreProvider must be overridden at the app root',
);
