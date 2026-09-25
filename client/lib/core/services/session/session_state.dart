import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'session_state.freezed.dart';

@freezed
sealed class SessionState with _$SessionState {
  const factory SessionState({
    required bool isLoaded,

    /// Set when reading persisted tokens failed. The session still counts as
    /// loaded so the app never blocks forever on the splash screen; callers
    /// must check this before trusting a partial read.
    Object? loadError,
    Uint8List? masterKey,
    String? accessToken,
    String? refreshToken,
  }) = _SessionState;
}
