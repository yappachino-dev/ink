import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ink/core/infrastructure/serialization/json_helpers.dart';

part 'project_dto.g.dart';
part 'project_dto.freezed.dart';

@freezed
sealed class ProjectDto with _$ProjectDto {
  const factory ProjectDto({
    required String id,

    @Uint8ListConverter() required Uint8List encryptedContent,

    required int version,

    @DateTimeUtcConverter() required DateTime createdAt,
    @DateTimeUtcConverter() required DateTime updatedAt,
    @DateTimeUtcConverter() DateTime? deletedAt,
  }) = _ProjectDto;

  factory ProjectDto.fromJson(Map<String, dynamic> json) =>
      _$ProjectDtoFromJson(json);
}
