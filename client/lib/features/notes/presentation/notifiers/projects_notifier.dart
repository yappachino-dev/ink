import 'package:ink/core/services/sync/sync_orchestrator.dart';
import 'package:ink/core/services/sync/sync_state.dart';
import 'package:ink/features/notes/domain/entities/project.dart';
import 'package:ink/features/notes/domain/models/project_creation_payload.dart';
import 'package:ink/features/notes/domain/notes_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'projects_notifier.g.dart';

@riverpod
class ProjectsNotifier extends _$ProjectsNotifier {
  @override
  Future<List<Project>> build() async {
    ref.listen(syncOrchestratorProvider, (previous, next) {
      if (next is SyncSuccess) {
        ref.invalidateSelf();
      }
    });

    final service = ref.watch(notesServiceProvider);

    final result = await service.getAllProjects();

    return result.fold(
      (projects) => projects,
      (failure) => throw failure,
    );
  }

  Future<void> createProject(ProjectCreationPayload payload) async {
    final currentProjects = state.value ?? [];

    final service = ref.read(notesServiceProvider);

    final result = await service.createProject(payload);

    result.fold(
      (note) => state = AsyncData([...currentProjects, note]),
      (failure) => throw failure,
    );
  }

  Future<void> saveProject(Project updatedProject) async {
    final previousState = state;
    final currentProjects = state.value ?? [];

    final index = currentProjects.indexWhere((n) => n.id == updatedProject.id);

    if (index >= 0) {
      final newList = List<Project>.from(currentProjects);
      newList[index] = updatedProject;
      state = AsyncData(newList);
    } else {
      state = AsyncData([...currentProjects, updatedProject]);
    }

    final service = ref.read(notesServiceProvider);

    final result = await service.saveProject(updatedProject);

    return result.fold(
      (_) {},
      (failure) {
        state = previousState;
      },
    );
  }

  Future<void> deleteProject(Project project) async {
    final previousState = state;
    final currentProjects = state.value ?? [];

    final index = currentProjects.indexWhere((n) => n.id == project.id);

    if (index >= 0) {
      final newList = List<Project>.from(currentProjects)..removeAt(index);
      state = AsyncData(newList);
    }
    final service = ref.read(notesServiceProvider);

    final result = await service.deleteProject(project);

    return result.fold(
      (_) {},
      (failure) {
        state = previousState;
      },
    );
  }
}
