import 'package:flutter_riverpod/misc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ink/features/auth/data/auth_service_impl.dart';
import 'package:ink/features/auth/domain/failures/auth_failure.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_notifier.g.dart';
part 'auth_notifier.freezed.dart';

enum RegisterResult { codeSent, alreadySent, processing, failure }

@freezed
sealed class AuthData with _$AuthData {
  const factory AuthData({
    String? email,
    String? password,

    @Default(false) bool isProcessing,
    AuthFailure? failure,
  }) = _AuthData;
}

@riverpod
class AuthNotifier extends _$AuthNotifier {
  KeepAliveLink? _link;

  @override
  AuthData build() {
    _link = ref.keepAlive();
    return const AuthData();
  }

  void abortFlow() {
    _link?.close();
  }

  Future<bool> login(String email, String password) async {
    if (state.isProcessing) return false;
    state = state.copyWith(isProcessing: true, failure: null);

    final result = await ref.read(authServiceProvider).login(email, password);

    if (!ref.mounted) return false;

    return result.fold(
      (success) {
        state = state.copyWith(isProcessing: false);
        _link?.close();
        return true;
      },
      (failure) {
        state = state.copyWith(isProcessing: false, failure: failure);
        return false;
      },
    );
  }

  Future<RegisterResult> setupRegister(String email, String password) async {
    if (email == state.email) return RegisterResult.alreadySent;

    if (state.isProcessing) return RegisterResult.processing;

    state = state.copyWith(
      email: email,
      password: password,
      isProcessing: true,
    );

    final result = await ref
        .read(authServiceProvider)
        .requestVerification(email);

    if (!ref.mounted) return RegisterResult.processing;

    state = state.copyWith(isProcessing: false);

    return result.fold(
      (success) => RegisterResult.codeSent,
      (failure) => RegisterResult.failure,
    );
  }

  Future<bool> resendCode() async {
    final email = state.email;
    final password = state.password;

    if (email == null || password == null || state.isProcessing) {
      return false;
    }

    state = state.copyWith(isProcessing: true);

    final result = await ref
        .read(authServiceProvider)
        .requestVerification(email);

    if (!ref.mounted) return false;

    state = state.copyWith(isProcessing: false);

    return result.fold(
      (success) {
        state = state.copyWith(isProcessing: false);
        return true;
      },
      (failure) {
        state = state.copyWith(isProcessing: false, failure: failure);
        return false;
      },
    );
  }

  Future<bool> confirmRegister(String code) async {
    final email = state.email;
    final password = state.password;

    if (email == null || password == null || state.isProcessing) {
      return false;
    }

    state = state.copyWith(isProcessing: true);

    final result = await ref
        .read(authServiceProvider)
        .register(email, password, code);

    if (!ref.mounted) return false;

    return result.fold(
      (success) {
        state = state.copyWith(isProcessing: false);
        _link?.close();
        return true;
      },
      (failure) {
        state = state.copyWith(isProcessing: false, failure: failure);
        return false;
      },
    );
  }
}
