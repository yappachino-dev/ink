import 'package:ink/features/notes/data/ports/notebooks_local_store.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notebooks_local_store_provider.g.dart';

@riverpod
NotebooksLocalStore notebooksLocalStore(Ref ref) => throw StateError(
  'notebooksLocalStoreProvider must be overridden at the app root',
);
