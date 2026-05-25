import 'dart:ui';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ink/core/infrastructure/serialization/json_helpers.dart';

part 'project_payload.freezed.dart';
part 'project_payload.g.dart';

@freezed
sealed class ProjectPayload with _$ProjectPayload {
  const factory ProjectPayload({
    required String title,
    required String emoji,
    @ColorConverter() required Color colorValue,
  }) = _ProjectPayload;

  factory ProjectPayload.fromJson(Map<String, dynamic> json) =>
      _$ProjectPayloadFromJson(json);
}
