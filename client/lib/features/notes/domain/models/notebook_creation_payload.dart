import 'package:freezed_annotation/freezed_annotation.dart';

part 'notebook_creation_payload.freezed.dart';

@freezed
sealed class NotebookCreationPayload with _$NotebookCreationPayload {
  const factory NotebookCreationPayload({
    required String title,
    required String emoji,
    required int colorValue,
  }) = _NotebookCreationPayload;
}
