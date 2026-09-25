import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ink/core/infrastructure/storage/secure_storage.dart';
import 'package:ink/core/services/session/session_manager.dart';
import 'package:mocktail/mocktail.dart';

class _MockSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late _MockSecureStorage storage;

  setUp(() {
    storage = _MockSecureStorage();
  });

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  group('SessionManager', () {
    test('loads persisted tokens on start', () async {
      when(
        () => storage.read(key: any(named: 'key')),
      ).thenAnswer((_) async => null);
      when(
        () => storage.read(key: 'access_token'),
      ).thenAnswer((_) async => 'access');
      when(
        () => storage.read(key: 'refresh_token'),
      ).thenAnswer((_) async => 'refresh');

      final container = ProviderContainer(
        overrides: [secureStorageProvider.overrideWithValue(storage)],
      );
      addTearDown(container.dispose);

      container.listen(sessionManagerProvider, (_, _) {});
      await settle();
      await settle();

      final state = container.read(sessionManagerProvider);
      expect(state.isLoaded, isTrue);
      expect(state.loadError, isNull);
      expect(state.accessToken, 'access');
      expect(state.refreshToken, 'refresh');
    });

    test(
      'records a load failure and still finishes loading instead of hanging',
      () async {
        when(
          () => storage.read(key: any(named: 'key')),
        ).thenThrow(Exception('keystore unavailable'));

        final container = ProviderContainer(
          overrides: [secureStorageProvider.overrideWithValue(storage)],
        );
        addTearDown(container.dispose);

        container.listen(sessionManagerProvider, (_, _) {});
        await settle();
        await settle();

        final state = container.read(sessionManagerProvider);
        expect(
          state.isLoaded,
          isTrue,
          reason: 'a failed read must not leave the app on the splash screen',
        );
        expect(state.loadError, isNotNull);
        expect(state.accessToken, isNull);
        expect(state.refreshToken, isNull);
      },
    );

    test('does not surface a partial read as a valid session', () async {
      when(
        () => storage.read(key: 'access_token'),
      ).thenAnswer((_) async => 'access');
      when(
        () => storage.read(key: 'refresh_token'),
      ).thenThrow(Exception('keystore unavailable'));

      final container = ProviderContainer(
        overrides: [secureStorageProvider.overrideWithValue(storage)],
      );
      addTearDown(container.dispose);

      container.read(sessionManagerProvider);
      await settle();
      await settle();

      final state = container.read(sessionManagerProvider);
      expect(state.loadError, isNotNull);
      // A successful access-token read must not survive a failing refresh-token
      // read: hasAccessToken would otherwise report a usable session.
      expect(state.accessToken, isNull);
      expect(state.refreshToken, isNull);
    });

    test('retry re-reads tokens and clears the load error', () async {
      var shouldFail = true;
      when(() => storage.read(key: 'access_token')).thenAnswer((_) async {
        if (shouldFail) throw Exception('keystore unavailable');
        return 'access';
      });
      when(() => storage.read(key: 'refresh_token')).thenAnswer((_) async {
        if (shouldFail) throw Exception('keystore unavailable');
        return 'refresh';
      });

      final container = ProviderContainer(
        overrides: [secureStorageProvider.overrideWithValue(storage)],
      );
      addTearDown(container.dispose);

      container.read(sessionManagerProvider);
      await settle();
      await settle();
      expect(container.read(sessionManagerProvider).loadError, isNotNull);

      shouldFail = false;
      container.read(sessionManagerProvider.notifier).retrySessionLoad();
      await settle();
      await settle();

      final state = container.read(sessionManagerProvider);
      expect(state.loadError, isNull);
      expect(state.isLoaded, isTrue);
      expect(state.accessToken, 'access');
    });

    test('retry is ignored unless a load actually failed', () async {
      var reads = 0;
      when(() => storage.read(key: any(named: 'key'))).thenAnswer((_) async {
        reads++;
        return null;
      });

      final container = ProviderContainer(
        overrides: [secureStorageProvider.overrideWithValue(storage)],
      );
      addTearDown(container.dispose);

      container.read(sessionManagerProvider);
      await settle();
      await settle();
      final readsAfterLoad = reads;

      // Healthy session: a stray programmatic retry must not re-read storage.
      container.read(sessionManagerProvider.notifier).retrySessionLoad();
      await settle();
      await settle();

      expect(reads, readsAfterLoad);
      expect(container.read(sessionManagerProvider).isLoaded, isTrue);
    });

    test(
      'a second retry while one is in flight does not re-read storage',
      () async {
        when(
          () => storage.read(key: any(named: 'key')),
        ).thenThrow(Exception('keystore unavailable'));

        final container = ProviderContainer(
          overrides: [secureStorageProvider.overrideWithValue(storage)],
        );
        addTearDown(container.dispose);

        container.read(sessionManagerProvider);
        await settle();
        await settle();

        // First retry moves the session into the loading state; a second call
        // while isLoaded is false must be dropped.
        container.read(sessionManagerProvider.notifier)
          ..retrySessionLoad()
          ..retrySessionLoad();
        await settle();
        await settle();

        final state = container.read(sessionManagerProvider);
        expect(state.isLoaded, isTrue);
        expect(state.loadError, isNotNull);
      },
    );

    test('setAuthTokens persists before completing', () async {
      when(
        () => storage.read(key: any(named: 'key')),
      ).thenAnswer((_) async => null);
      final writes = <String>[];
      when(
        () => storage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((invocation) async {
        final key = invocation.namedArguments[#key];
        final value = invocation.namedArguments[#value];
        writes.add('$key=$value');
      });

      final container = ProviderContainer(
        overrides: [secureStorageProvider.overrideWithValue(storage)],
      );
      addTearDown(container.dispose);

      container.read(sessionManagerProvider);
      await settle();
      await settle();

      await container
          .read(sessionManagerProvider.notifier)
          .setAuthTokens('a', 'r');

      expect(writes, ['access_token=a', 'refresh_token=r']);
    });
  });
}
