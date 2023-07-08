import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:podd_app/app_theme.dart';
import 'package:podd_app/components/waiting_screen.dart';
import 'package:podd_app/constants.dart';
import 'package:podd_app/locator.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:podd_app/router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ohtk_view_model.dart';

class OhtkApp extends StatelessWidget {
  const OhtkApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Future.wait([
          locator.allReady(),
          fetchLocaleFromPreference(),
        ]),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          setupAppLocalization();
          if (!snapshot.hasData) {
            return const MaterialApp(home: WaitingScreen());
          }
          final appViewModel = AppViewModel();
          var locale = snapshot.data[1];
          return OverlaySupport.global(
            child: ListenableBuilder(
              listenable: appViewModel,
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
                ],
                locale: locale,
                theme: locator<AppTheme>().themeData,
                routerConfig: OhtkRouter().getRouter(),
              ),
            ),
          );
        });
  }

  /*
  To get local from SharedPreferences if exists
   */
  Future<Locale> fetchLocaleFromPreference() async {
    var prefs = await SharedPreferences.getInstance();
    var languageCode = prefs.getString(languageKey) ?? "en";
    return Locale(languageCode, '');
  }
}
