import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'project_creation_payload.freezed.dart';

@freezed
sealed class ProjectCreationPayload with _$ProjectCreationPayload {
  const factory ProjectCreationPayload({
    required String title,
    required String emoji,
    required Color color,
  }) = _ProjectCreationPayload;
}
