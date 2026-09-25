import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/app/init.dart';
import 'package:ink/app/navigation/app_router.dart';
import 'package:ink/core/presentation/theme/app_theme.dart';
import 'package:ink/core/presentation/theme/theme_notifier.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';

Future<void> main() async {
  final sharedPrefs = await initializeGlobalSettings();

  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('assets/fonts/inter/OFL.txt');
    yield LicenseEntryWithLineBreaks(['Inter'], license);
  });

  // ProviderScope must be written literally as the runApp child so tooling
  // (and the riverpod lint) can recognize it as the unscoped root.
  runApp(
    ProviderScope(
      overrides: buildOverrides(sharedPrefs),
      child: wrapWithTranslation(child: const MyApp()),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(themeProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: context.t.common.appName,
      debugShowCheckedModeBanner: false,

      locale: TranslationProvider.of(context).flutterLocale,
      supportedLocales: AppLocaleUtils.supportedLocales,
      localizationsDelegates: const [
        ...GlobalMaterialLocalizations.delegates,
        FlutterQuillLocalizations.delegate,
      ],

      theme: AppTheme.light(prefs.palette),
      darkTheme: AppTheme.dark(prefs.palette),
      themeMode: prefs.mode,

      routerConfig: router,
    );
  }
}
