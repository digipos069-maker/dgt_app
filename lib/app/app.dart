import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../localization/app_localizations.dart';
import '../localization/language_controller.dart';
import '../router/app_router.dart';
import '../theme/app_theme.dart';
import '../theme/theme_controller.dart';
import '../features/auth/application/auth_controller.dart';

class DgtApp extends ConsumerStatefulWidget {
  const DgtApp({super.key});

  @override
  ConsumerState<DgtApp> createState() => _DgtAppState();
}

class _DgtAppState extends ConsumerState<DgtApp> {
  bool _didCompleteStartup = false;

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(languageControllerProvider);
    final themeMode = ref.watch(themeControllerProvider);
    final authState = ref.watch(authControllerProvider);
    if (!_didCompleteStartup && !authState.isLoading) {
      _didCompleteStartup = true;
    }

    if (!_didCompleteStartup) {
      return MaterialApp(
        title: 'DGT',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(locale),
        darkTheme: AppTheme.dark(locale),
        themeMode: themeMode,
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'DGT',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: AppTheme.light(locale),
      darkTheme: AppTheme.dark(locale),
      themeMode: themeMode,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
    );
  }
}
