import 'package:ink/features/notes/data/ports/projects_local_store.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'projects_local_store_provider.g.dart';

@riverpod
ProjectsLocalStore projectsLocalStore(Ref ref) => throw StateError(
  'projectsLocalStoreProvider must be overridden at the app root',
);
