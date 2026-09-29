// Step 9b: the profile rebuilt as a clean slate (§7.4, D-4, D-5).
//
// It used to open on an avatar labelled "Name" and "Email" - literal
// translation placeholders, not data - above a "Create account" row whose
// onTap did nothing, with an entire second copy of the screen behind a
// `_hasAccount` flag hardcoded to false.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ink/core/config/user_config.dart';
import 'package:ink/core/presentation/providers/status_providers.dart';
import 'package:ink/core/presentation/theme/app_theme.dart';
import 'package:ink/core/presentation/theme/palettes.dart';
import 'package:ink/features/auth/domain/auth_providers.dart';
import 'package:ink/features/auth/domain/auth_service.dart';
import 'package:ink/features/profile/presentation/screens/profile_screen.dart';
import 'package:ink/features/profile/presentation/widgets/security_card.dart';
import 'package:ink/features/profile/presentation/widgets/settings_tile.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Auth extends Mock implements AuthService {}

void main() {
  SharedPreferences.setMockInitialValues({});

  late SharedPreferences prefs;
  late _Auth auth;

  setUp(() async {
    prefs = await SharedPreferences.getInstance();
    auth = _Auth();
    when(auth.logout).thenAnswer((_) async {});
  });

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userPreferencesProvider.overrideWithValue(UserConfig(prefs)),
          authServiceProvider.overrideWithValue(auth),
          isOfflineProvider.overrideWithValue(false),
          syncActivityProvider.overrideWithValue(SyncActivity.idle),
        ],
        child: TranslationProvider(
          child: MaterialApp(
            theme: AppTheme.light(InkPalette.forest),
            home: const ProfileScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('the placeholder identity header is gone', (tester) async {
    await pump(tester);

    // This used to assert that the placeholder strings were absent by way of
    // `t.profile.personal.name` and `.email`, which kept two dead catalogue
    // keys alive for the sole purpose of asserting they were dead. The values
    // were "Name" and "Email", generic enough that the assertion proved little.
    // The avatar is what the header actually was, so assert on that. The bottom
    // nav also uses a `person_outline`, but that is a different screen and the
    // nav is not mounted here.
    expect(find.byIcon(Icons.person_outline), findsNothing);
  });

  testWidgets('the dead controls are gone', (tester) async {
    await pump(tester);

    // The strings are gone from the catalogue too, so this pins the copy as
    // well as the widget.
    expect(find.textContaining('Create account'), findsNothing);
    expect(find.textContaining('Change name'), findsNothing);
    expect(find.textContaining('Change encryption'), findsNothing);
    expect(find.text(t.profile.personal.changeName), findsNothing);
    expect(find.text(t.profile.personal.changeEncryption), findsNothing);
  });

  testWidgets('every remaining row does something', (tester) async {
    await pump(tester);

    // A row with no behaviour is worse than no row, so nothing here may be a
    // dead end. The security statements are the deliberate exception: they
    // render without an arrow so they do not look tappable.
    final tiles = tester.widgetList<SettingsTile>(find.byType(SettingsTile));
    expect(tiles, isNotEmpty);

    for (final tile in tiles.where((t) => t.showArrow)) {
      expect(tile.title.trim(), isNotEmpty);
    }
  });

  testWidgets('the wired settings are kept', (tester) async {
    await pump(tester);

    expect(find.text(t.profile.settings.personalization), findsOneWidget);
    expect(find.text(t.profile.settings.appearance.title), findsOneWidget);
    expect(find.text(t.profile.personal.logout), findsOneWidget);
  });

  testWidgets('the settings that did nothing are gone', (tester) async {
    // "Date and time" persisted a timezone that nothing read: every timestamp
    // went through the device zone, so it promised behaviour that did not
    // exist. "Widgets" was worse - three switches over a hardcoded list of
    // `enabled:` literals, so toggling one rebuilt the same value and the
    // switch could not change anything even in memory.
    //
    // Both are asserted absent so that re-adding a setting with no consumer
    // behind it fails here rather than shipping.
    await pump(tester);

    final tiles = tester
        .widgetList<SettingsTile>(find.byType(SettingsTile))
        .map((tile) => tile.title)
        .toList();

    expect(tiles, isNot(contains('Date and time')));
    expect(tiles, isNot(contains('Widgets')));
  });

  group('the security card states what actually protects the notes', () {
    testWidgets('encryption is stated as a fact, not a promise', (
      tester,
    ) async {
      await pump(tester);

      expect(find.byType(SecurityCard), findsOneWidget);
      // The same verifiable claim the welcome screen makes.
      expect(find.text(t.welcome.thesis), findsOneWidget);
    });

    testWidgets('a free user never learns syncing exists', (tester) async {
      await pump(tester);

      // `localOnly` defaults to true, so a fresh install is the free tier.
      expect(find.text(t.trust.onDeviceMessage), findsOneWidget);
      expect(find.text(t.trust.synced), findsNothing);
    });

    testWidgets('a pro user sees real sync state', (tester) async {
      await UserConfig(prefs).setLocalOnly(local: false);
      await pump(tester);

      expect(find.text(t.trust.syncedMessage), findsOneWidget);
      expect(find.text(t.trust.onDeviceMessage), findsNothing);
    });
  });
}
