import 'package:freezed_annotation/freezed_annotation.dart';

part 'request_verification_dto.g.dart';
part 'request_verification_dto.freezed.dart';

@freezed
sealed class RequestVerificationDto with _$RequestVerificationDto {
  const factory RequestVerificationDto({
    required String email,
  }) = _RequestVerificationDto;

  factory RequestVerificationDto.fromJson(Map<String, dynamic> json) =>
      _$RequestVerificationDtoFromJson(json);
}
