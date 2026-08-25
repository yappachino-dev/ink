import 'package:drift/drift.dart';
import 'package:ink/app/database/database.dart';
import 'package:ink/features/notes/domain/entities/encrypted_project.dart';

extension ProjectModelToEncrypted on ProjectModel {
  EncryptedProject toDomain() => EncryptedProject(
    id: id,

    encryptedContent: encryptedContent,

    localVersion: localVersion,
    lastSyncedVersion: lastSyncedVersion,
    syncStatus: syncStatus,

    createdAt: createdAt,
    updatedAt: updatedAt,
    deletedAt: deletedAt,
  );
}

extension EncryptedProjectToCompanion on EncryptedProject {
  ProjectsCompanion toCompanion() => ProjectsCompanion.insert(
    id: Value(id),

    encryptedContent: encryptedContent,

    localVersion: Value(localVersion),
    lastSyncedVersion: Value(lastSyncedVersion),
    syncStatus: Value(syncStatus),

    createdAt: Value(createdAt),
    updatedAt: Value(updatedAt),
    deletedAt: Value(deletedAt),
  );

  ProjectConflictsCompanion toConflictCompanion() =>
      ProjectConflictsCompanion.insert(
        id: id,
        encryptedContent: encryptedContent,
        version: localVersion,
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: Value(deletedAt),
      );
}
