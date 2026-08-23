import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/app/init.dart';
import 'package:ink/app/navigation/app_router.dart';
import 'package:ink/core/presentation/theme/app_theme.dart';
import 'package:ink/core/presentation/theme/theme_notifier.dart';
import 'package:ink/i18n/strings.g.dart';

void main() async {
  final sharedPrefs = await initializeGlobalSettings();

  const root = MyApp();

  final app = await wrapWithProviderScope(
    child: wrapWithTranslation(child: root),
    sharedPrefs: sharedPrefs,
  );

  runApp(app);
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
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],

      theme: AppTheme.light(prefs.palette),
      darkTheme: AppTheme.dark(prefs.palette),
      themeMode: prefs.mode,

      routerConfig: router,
    );
  }
}
