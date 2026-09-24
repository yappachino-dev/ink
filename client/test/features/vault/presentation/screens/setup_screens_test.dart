import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ink/core/domain/result.dart';
import 'package:ink/core/presentation/theme/app_theme.dart';
import 'package:ink/core/presentation/theme/palettes.dart';
import 'package:ink/core/presentation/widgets/wide_filled_button.dart';
import 'package:ink/features/vault/domain/entities/key_type.dart';
import 'package:ink/features/vault/domain/failures/vault_failure.dart';
import 'package:ink/features/vault/domain/vault_providers.dart';
import 'package:ink/features/vault/domain/vault_service.dart';
import 'package:ink/features/vault/presentation/notifiers/vault_setup_notifier.dart';
import 'package:ink/features/vault/presentation/screens/setup_recovery_screen.dart';
import 'package:ink/features/vault/presentation/screens/setup_verify_screen.dart';
import 'package:ink/i18n/strings.g.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        SystemChannels.platform,
        (_) async => null,
      );

  testWidgets(
    'recovery screen displays all phrase words and copies the phrase',
    (tester) async {
      const phrase = [
        'alpha',
        'bravo',
        'charlie',
        'delta',
        'echo',
        'foxtrot',
        'golf',
        'hotel',
        'india',
        'juliet',
        'kilo',
        'lima',
      ];
      await _pumpScreen(
        tester,
        const SetupRecoveryScreen(),
        overrides: [
          vaultSetupProvider.overrideWithValue(
            const VaultSetupData(
              generatedRecoveryPhrase: phrase,
              verifyIndices: [1, 4, 9],
            ),
          ),
        ],
      );

      for (final word in phrase) {
        expect(find.text(word), findsOneWidget);
      }
      for (var index = 1; index <= 12; index++) {
        expect(find.text('$index'), findsOneWidget);
      }

      final copyButton = find.text('Copy to clipboard');
      await tester.ensureVisible(copyButton);
      await tester.pumpAndSettle();
      await tester.tap(copyButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Phrase copied to clipboard'), findsOneWidget);
    },
  );

  testWidgets(
    'verification screen rejects a wrong phrase and commits a retry',
    (tester) async {
      final service = _FakeVaultService();
      await _pumpScreen(
        tester,
        const SetupVerifyScreen(),
        overrides: [
          vaultServiceProvider.overrideWithValue(service),
          vaultRandomServiceProvider.overrideWithValue(_FixedRandomService()),
        ],
      );

      final container = ProviderScope.containerOf(
        tester.element(find.byType(SetupVerifyScreen)),
      );
      container.read(vaultSetupProvider.notifier).setupPin('1234');
      final state = container.read(vaultSetupProvider);
      final expectedPhrase = state.generatedRecoveryPhrase.join();
      final inputs = [
        for (final index in state.verifyIndices)
          state.generatedRecoveryPhrase[index],
      ];

      final fields = find.byType(TextField);
      final continueButton = find.widgetWithText(WideFilledButton, 'Continue');
      expect(tester.widget<WideFilledButton>(continueButton).onPressed, isNull);

      await tester.enterText(fields.at(0), 'wrong');
      await tester.enterText(fields.at(1), inputs[1]);
      await tester.enterText(fields.at(2), inputs[2]);
      await tester.pump();
      expect(
        tester.widget<WideFilledButton>(continueButton).onPressed,
        isNotNull,
      );

      await tester.ensureVisible(continueButton);
      await tester.pumpAndSettle();
      await tester.tap(continueButton);
      await tester.pumpAndSettle();
      expect(service.initializeCalls, 0);
      expect(find.text('Words do not match. Try again!'), findsOneWidget);

      await tester.enterText(fields.at(0), ' ${inputs[0]} ');
      await tester.pumpAndSettle();
      expect(
        tester.widget<WideFilledButton>(continueButton).onPressed,
        isNotNull,
      );

      await tester.ensureVisible(continueButton);
      await tester.pumpAndSettle();
      await tester.tap(continueButton);
      await tester.pumpAndSettle();
      expect(service.initializeCalls, 1);
      expect(service.lastSecrets, {
        KeyType.pin: '1234',
        KeyType.recoveryPhrase: expectedPhrase,
      });
    },
  );
}

Future<void> _pumpScreen(
  WidgetTester tester,
  Widget screen, {
  required List<dynamic> overrides,
}) {
  return tester.pumpWidget(
    ProviderScope(
      overrides: overrides.cast(),
      child: TranslationProvider(
        child: MaterialApp(
          theme: AppTheme.light(InkPalette.forest),
          home: screen,
        ),
      ),
    ),
  );
}

class _FixedRandomService implements VaultRandomService {
  @override
  Uint8List generateBytes(int length) => Uint8List(length);
}

class _FakeVaultService implements VaultService {
  int initializeCalls = 0;
  Map<KeyType, String>? lastSecrets;

  @override
  Future<Result<void, VaultFailure>> intializeNewVault(
    Map<KeyType, String> initialSecrets,
  ) async {
    initializeCalls++;
    lastSecrets = Map.of(initialSecrets);
    return const Success(null);
  }

  @override
  Future<Result<List<KeyType>, VaultFailure>> getUnlockMethods() async =>
      const Success([]);

  @override
  Future<Result<void, VaultFailure>> pullKeys() async => const Success(null);

  @override
  Future<Result<void, VaultFailure>> pushKeys() async => const Success(null);

  @override
  Future<Result<void, VaultFailure>> unlock(
    KeyType type,
    String secret,
  ) async => const Success(null);
}
