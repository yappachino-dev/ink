import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ink/core/domain/result.dart';
import 'package:ink/features/auth/domain/auth_providers.dart';
import 'package:ink/features/auth/domain/auth_service.dart';
import 'package:ink/features/auth/domain/failures/auth_failure.dart';
import 'package:ink/features/auth/presentation/notifiers/auth_notifier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('verification request failure is exposed in notifier state', () async {
    final service = _FakeAuthService(
      requestVerificationResult: const Failure(InvalidCredentials()),
    );
    final container = ProviderContainer(
      overrides: [authServiceProvider.overrideWithValue(service)],
    );
    addTearDown(container.dispose);
    container.listen(authProvider, (_, _) {});

    final result = await container
        .read(authProvider.notifier)
        .setupRegister('person@example.com', 'password123');

    expect(result, RegisterResult.failure);
    expect(
      container.read(authProvider).failure,
      const InvalidCredentials(),
    );
    expect(container.read(authProvider).isProcessing, isFalse);
  });

  test('login blocks duplicate submissions and clears processing', () async {
    final service = _FakeAuthService();
    final container = ProviderContainer(
      overrides: [authServiceProvider.overrideWithValue(service)],
    );
    addTearDown(container.dispose);
    container.listen(authProvider, (_, _) {});
    final notifier = container.read(authProvider.notifier);

    final first = notifier.login('person@example.com', 'password123');
    expect(container.read(authProvider).isProcessing, isTrue);
    expect(await notifier.login('person@example.com', 'password123'), isFalse);

    service.completeLogin(const Success(null));
    expect(await first, isTrue);
    expect(service.loginCalls, 1);
    expect(container.read(authProvider).isProcessing, isFalse);
  });

  test('repeated verification request for same email is ignored', () async {
    final service = _FakeAuthService();
    final container = ProviderContainer(
      overrides: [authServiceProvider.overrideWithValue(service)],
    );
    addTearDown(container.dispose);
    container.listen(authProvider, (_, _) {});
    final notifier = container.read(authProvider.notifier);

    expect(
      await notifier.setupRegister('person@example.com', 'password123'),
      RegisterResult.codeSent,
    );
    expect(container.read(authProvider).isProcessing, isFalse);
    expect(
      await notifier.setupRegister('person@example.com', 'different'),
      RegisterResult.alreadySent,
    );
    expect(service.verificationCalls, 1);
  });

  test('confirmation exposes failure and clears processing', () async {
    final service = _FakeAuthService(
      registerResult: const Failure(EmailAlreadyInUse()),
    );
    final container = ProviderContainer(
      overrides: [authServiceProvider.overrideWithValue(service)],
    );
    addTearDown(container.dispose);
    container.listen(authProvider, (_, _) {});
    final notifier = container.read(authProvider.notifier);

    await notifier.setupRegister('person@example.com', 'password123');
    final confirmed = await notifier.confirmRegister('123456');

    expect(confirmed, isFalse);
    expect(
      container.read(authProvider).failure,
      const EmailAlreadyInUse(),
    );
    expect(container.read(authProvider).isProcessing, isFalse);
  });
}

class _FakeAuthService implements AuthService {
  _FakeAuthService({
    this.requestVerificationResult = const Success(null),
    this.registerResult = const Success(null),
  });

  final Result<void, AuthFailure> requestVerificationResult;
  final Result<void, AuthFailure> registerResult;
  final _loginCompleter = Completer<Result<void, AuthFailure>>();

  int loginCalls = 0;
  int verificationCalls = 0;

  void completeLogin(Result<void, AuthFailure> result) {
    _loginCompleter.complete(result);
  }

  @override
  Future<Result<void, AuthFailure>> login(
    String email,
    String password,
  ) async {
    loginCalls++;
    return _loginCompleter.future;
  }

  @override
  Future<Result<void, AuthFailure>> register(
    String email,
    String password,
    String code,
  ) async => registerResult;

  @override
  Future<Result<void, AuthFailure>> requestVerification(String email) async {
    verificationCalls++;
    return requestVerificationResult;
  }

  @override
  Future<void> logout() async {}
}
