import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'session_state.freezed.dart';

@freezed
sealed class SessionState with _$SessionState {
  const factory SessionState({
    Uint8List? masterKey,
    String? accessToken,
  }) = _SessionState;
}
