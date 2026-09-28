import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ink/core/domain/sync_status.dart';

part 'notebook.freezed.dart';

@freezed
sealed class Notebook with _$Notebook {
  const factory Notebook({
    required String id,

    required String title,
    required String emoji,
    required int colorValue,

    required int localVersion,
    required int lastSyncedVersion,
    required SyncStatus syncStatus,

    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _Notebook;

  const Notebook._();
}
