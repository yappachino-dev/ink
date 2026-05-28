import 'dart:typed_data';

import 'package:ink/core/infrastructure/grpc/gen/sync/v1/sync.pb.dart' as pb;
import 'package:ink/core/services/sync/sync_status.dart';
import 'package:ink/features/notes/domain/entities/encrypted_project.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';

// extension ProjectDtoToEncrypted on ProjectDto {
//   EncryptedProject toDomain() => EncryptedProject(
//     id: id,
//
//     encryptedContent: encryptedContent,
//
//     localVersion: version,
//     lastSyncedVersion: version,
//     syncStatus: SyncStatus.synced,
//
//     createdAt: createdAt,
//     updatedAt: updatedAt,
//     deletedAt: deletedAt,
//   );
// }

extension ProtoProjectToEncrypted on pb.Project {
  EncryptedProject toDomain() => EncryptedProject(
    id: id,

    encryptedContent: Uint8List.fromList(encryptedContent),

    localVersion: version,
    lastSyncedVersion: version,
    syncStatus: SyncStatus.synced,

    createdAt: createdAt.toDateTime(),
    updatedAt: updatedAt.toDateTime(),
    deletedAt: hasDeletedAt() ? deletedAt.toDateTime() : null,
  );
}

// extension EncryptedProjectToDto on EncryptedProject {
//   ProjectDto toDto() => ProjectDto(
//     id: id,
//
//     encryptedContent: encryptedContent,
//
//     version: lastSyncedVersion,
//
//     createdAt: createdAt,
//     updatedAt: updatedAt,
//     deletedAt: deletedAt,
//   );
// }

extension EncryptedProjectToProto on EncryptedProject {
  pb.Project toProto() => pb.Project(
    id: id,

    encryptedContent: encryptedContent,

    version: lastSyncedVersion,

    createdAt: Timestamp.fromDateTime(createdAt),
    updatedAt: Timestamp.fromDateTime(updatedAt),
    deletedAt: deletedAt != null ? Timestamp.fromDateTime(deletedAt!) : null,
  );
}
