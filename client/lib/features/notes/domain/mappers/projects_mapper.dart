import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:ink/features/notes/domain/entities/encrypted_project.dart';
import 'package:ink/features/notes/domain/entities/project.dart';

extension ProjectToEncrypted on Project {
  EncryptedProject toEncrypted({
    required Uint8List encryptedContent,
  }) => EncryptedProject(
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

extension EncryptedToProject on EncryptedProject {
  Project toProject({
    required String title,
    required String emoji,
    required Color color,
  }) => Project(
    id: id,

    title: title,
    emoji: emoji,
    color: color,

    localVersion: localVersion,
    lastSyncedVersion: lastSyncedVersion,
    syncStatus: syncStatus,

    createdAt: createdAt,
    updatedAt: updatedAt,
    deletedAt: deletedAt,
  );
}
