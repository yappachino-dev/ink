import 'dart:ui';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ink/core/infrastructure/serialization/json_helpers.dart';

part 'notebook_payload.freezed.dart';
part 'notebook_payload.g.dart';

@freezed
sealed class NotebookPayload with _$NotebookPayload {
  const factory NotebookPayload({
    required String title,
    required String emoji,
    @ColorConverter() required Color colorValue,
  }) = _NotebookPayload;

  factory NotebookPayload.fromJson(Map<String, dynamic> json) =>
      _$NotebookPayloadFromJson(json);
}
