import 'dart:typed_data';

import 'package:ink/core/domain/sync_status.dart';
import 'package:ink/core/infrastructure/grpc/gen/sync/v1/sync.pb.dart' as pb;
import 'package:ink/features/notes/domain/entities/encrypted_notebook.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';

extension ProtoNotebookToEncrypted on pb.Notebook {
  EncryptedNotebook toDomain() => EncryptedNotebook(
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

extension EncryptedNotebookToProto on EncryptedNotebook {
  pb.Notebook toProto() => pb.Notebook(
    id: id,

    encryptedContent: encryptedContent,

    version: lastSyncedVersion,

    createdAt: Timestamp.fromDateTime(createdAt),
    updatedAt: Timestamp.fromDateTime(updatedAt),
    deletedAt: deletedAt != null ? Timestamp.fromDateTime(deletedAt!) : null,
  );
}
