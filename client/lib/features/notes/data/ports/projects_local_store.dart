import 'dart:typed_data';

import 'package:ink/core/services/sync/sync_types.dart';
import 'package:ink/features/notes/domain/entities/encrypted_project.dart';

abstract interface class ProjectsLocalStore {
  Future<EncryptedProject> createProject(Uint8List encryptedContent);
  Future<void> saveProject(EncryptedProject project);
  Future<EncryptedProject?> getProject(String id);
  Future<List<EncryptedProject>> getAllProjects();
  Future<void> deleteProject(String id);
  Future<List<EncryptedProject>> getPendingProjects();
  Future<List<EncryptedProject>> getProjectsByIds(List<String> ids);
  Future<void> acknowledgePushedProjects(List<SyncAck> acknowledgements);
  Future<void> applyRemoteProjects(List<EncryptedProject> remoteData);
}
