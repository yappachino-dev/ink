import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ink/core/domain/sync_status.dart';

part 'project.freezed.dart';

@freezed
sealed class Project with _$Project {
  const factory Project({
    required String id,

    required String title,
    required String emoji,
    required Color color,

    required int localVersion,
    required int lastSyncedVersion,
    required SyncStatus syncStatus,

    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? deletedAt,
  }) = _Project;

  const Project._();
}
