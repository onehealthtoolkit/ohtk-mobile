import 'dart:async';

import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:podd_app/app_theme.dart';
import 'package:podd_app/components/error_screen.dart';
import 'package:podd_app/components/restart_widget.dart';
import 'package:podd_app/components/waiting_screen.dart';
import 'package:podd_app/constants.dart';
import 'package:podd_app/locator.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:podd_app/l10n/app_localizations.dart';
import 'package:podd_app/router.dart';
import 'package:podd_app/services/gql_service.dart';
import 'package:podd_app/ui/welcome/welcome_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ohtk_view_model.dart';

class OhtkApp extends StatelessWidget {
  final StreamController<String> progressStream;

  const OhtkApp(
    this.progressStream, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _resolveStartup(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          setupAppLocalization();
          if (snapshot.hasError) {
            return MaterialApp(home: ErrorScreen(snapshot.error.toString()));
          }
          if (!snapshot.hasData) {
            return MaterialApp(home: WaitingScreen(progressStream));
          }
          final startup = snapshot.data as _StartupState;
          var locale = startup.locale;
          var setupComplete = startup.setupComplete;
          if (!setupComplete) {
            return _buildApp(
              locale: locale,
              child: WelcomeView(
                onContinue: () {
                  if (context.mounted) RestartWidget.restartApp(context);
                },
              ),
            );
          }
          final appViewModel = AppViewModel();
          final appTheme = locator<AppTheme>();
          return OverlaySupport.global(
            child: ListenableBuilder(
              listenable: Listenable.merge([appViewModel, appTheme]),
              builder: (context, child) => MaterialApp.router(
                debugShowCheckedModeBanner: false,
                title: 'OHTK Mobile',
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [
                  Locale('en', ''), // English, no country code
                  Locale('th', ''), // Thai, no country code
                  Locale('km', ''), // Cambodia
                  Locale('lo', ''), // Lao
                  Locale('fr', ''), // French
                  Locale('es', ''), // Spanish
                  Locale('my', ''), // Burmese
                ],
                locale: locale,
                theme: appTheme.themeData,
                routerConfig:
                    OhtkRouter().getRouter(setupComplete: setupComplete),
              ),
            ),
          );
        });
  }

  Future<_StartupState> _resolveStartup() async {
    final locale = await fetchLocaleFromPreference();
    final setupComplete = await fetchSetupComplete();
    if (!setupComplete) {
      await Future.wait([
        locator.isReady<GqlService>(timeout: const Duration(seconds: 15)),
        locator.isReady<AppTheme>(timeout: const Duration(seconds: 15)),
      ]);
      return _StartupState(locale: locale, setupComplete: false);
    }

    await locator.allReady(timeout: const Duration(seconds: 60));
    return _StartupState(locale: locale, setupComplete: true);
  }

  Widget _buildApp({
    required Locale locale,
    required Widget child,
  }) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OHTK Mobile',
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('th', ''),
        Locale('km', ''),
        Locale('lo', ''),
        Locale('fr', ''),
        Locale('es', ''),
        Locale('my', ''),
      ],
      locale: locale,
      theme: locator<AppTheme>().themeData,
      home: child,
    );
  }

  /*
  To get local from SharedPreferences if exists
   */
  Future<Locale> fetchLocaleFromPreference() async {
    var prefs = await SharedPreferences.getInstance();
    var languageCode = prefs.getString(languageKey) ?? "en";
    return Locale(languageCode, '');
  }

  /*
  Both language and server must be picked at least once for the app to skip
  the first-launch Welcome gate.
   */
  Future<bool> fetchSetupComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(languageKey) != null &&
        prefs.getString(serverDomainKey) != null;
  }
}

class _StartupState {
  final Locale locale;
  final bool setupComplete;

  const _StartupState({
    required this.locale,
    required this.setupComplete,
  });
}
