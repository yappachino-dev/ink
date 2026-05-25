import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ink/core/infrastructure/serialization/json_helpers.dart';

part 'note_dto.g.dart';
part 'note_dto.freezed.dart';

@freezed
sealed class NoteDto with _$NoteDto {
  const factory NoteDto({
    required String id,

    @Uint8ListConverter() required Uint8List encryptedTitle,
    @Uint8ListConverter() required Uint8List encryptedContent,

    required int version,

    @DateTimeUtcConverter() required DateTime createdAt,
    @DateTimeUtcConverter() required DateTime updatedAt,
    @DateTimeUtcConverter() DateTime? deletedAt,

    String? projectId,
  }) = _NoteDto;

  factory NoteDto.fromJson(Map<String, dynamic> json) =>
      _$NoteDtoFromJson(json);
}
