import 'dart:typed_data';

import 'package:ink/core/infrastructure/grpc/gen/sync/v1/sync.pb.dart' as pb;
import 'package:ink/core/services/sync/sync_status.dart';
import 'package:ink/features/notes/domain/entities/encrypted_note.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';

extension ProtoNoteToEncrypted on pb.Note {
  EncryptedNote toDomain() => EncryptedNote(
    id: id,
    encryptedTitle: Uint8List.fromList(encryptedTitle),
    encryptedContent: Uint8List.fromList(encryptedContent),

    localVersion: version,
    lastSyncedVersion: version,
    syncStatus: SyncStatus.synced,

    createdAt: createdAt.toDateTime(),
    updatedAt: updatedAt.toDateTime(),
    deletedAt: hasDeletedAt() ? deletedAt.toDateTime() : null,

    projectId: hasProjectId() ? projectId : null,
  );
}

extension EncryptedNoteToProto on EncryptedNote {
  pb.Note toProto() => pb.Note(
    id: id,
    encryptedTitle: encryptedTitle,
    encryptedContent: encryptedContent,

    version: lastSyncedVersion,

    createdAt: Timestamp.fromDateTime(createdAt),
    updatedAt: Timestamp.fromDateTime(updatedAt),
    deletedAt: deletedAt != null ? Timestamp.fromDateTime(deletedAt!) : null,

    projectId: projectId,
  );
}
