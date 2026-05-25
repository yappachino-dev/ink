import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_response_dto.g.dart';
part 'auth_response_dto.freezed.dart';

@freezed
sealed class AuthResponseDto with _$AuthResponseDto {
  const factory AuthResponseDto({required String accessToken}) =
      _AuthResponseDto;

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseDtoFromJson(json);
}
