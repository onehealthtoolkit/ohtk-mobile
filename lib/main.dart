import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:podd_app/services/auth_service.dart';
import 'package:podd_app/services/httpclient.dart';
import 'package:podd_app/ui/home/home_view.dart';
import 'package:podd_app/ui/login/login_view.dart';
import 'package:podd_app/ui/login/login_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked/stacked_annotations.dart';

import 'firebase_options.dart';
import 'locator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();

  await initHiveForFlutter();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: Environment.dev,
  );
  setupLocator(environment);
  runApp(
    const RestartWidget(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Future.wait([
          locator.allReady(),
          _fetchLocale(),
        ]),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return const MaterialApp(home: _WaitingScreen());
          }
          return OverlaySupport.global(
            child: MaterialApp(
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
                Locale('hi', ''), // India
              ],
              localeResolutionCallback: (deviceLocale, supportedLocales) {
                String? languageCode = snapshot.data[1];
                if (languageCode != null) {
                  return Locale(languageCode, '');
                }
                if (supportedLocales
                    .map((e) => e.languageCode)
                    .contains(deviceLocale?.languageCode)) {
                  return deviceLocale;
                } else {
                  return const Locale('en', '');
                }
              },
              theme: ThemeData(
                // This is the theme of your application.
                //
                // Try running your application with "flutter run". You'll see the
                // application has a blue toolbar. Then, without quitting the app, try
                // changing the primarySwatch below to Colors.green and then invoke
                // "hot reload" (press "r" in the console where you ran "flutter run",
                // or simply save your changes to "hot reload" in a Flutter IDE).
                // Notice that the counter didn't reset back to zero; the application
                // is not restarted.
                primarySwatch: Colors.blue,
              ),
              home: snapshot.hasData ? _App() : const _WaitingScreen(),
            ),
          );
        });
  }

/*
  To get local from SharedPreferences if exists
   */
  Future<String?> _fetchLocale() async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.getString(languageKey) ?? "en";
  }
}

class _WaitingScreen extends StatelessWidget {
  const _WaitingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<_AppViewModel>.reactive(
      viewModelBuilder: () => _AppViewModel(),
      builder: (context, viewModel, child) =>
          viewModel.isLogin == true ? const HomeView() : const LoginView(),
    );
  }
}

class _AppViewModel extends ReactiveViewModel {
  final IAuthService authService = locator<IAuthService>();
  bool? get isLogin => authService.isLogin;

  late Timer timer;

  _AppViewModel() : super() {
    authService.requestAccessTokenIfExpired();
    timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      authService.requestAccessTokenIfExpired();
    });
  }

  @override
  List<ReactiveServiceMixin> get reactiveServices =>
      [authService as AuthService];
}

class RestartWidget extends StatefulWidget {
  final Widget child;

  const RestartWidget({required this.child, Key? key}) : super(key: key);

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>()?.restartApp();
  }

  @override
  _RestartWidgetState createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    const String environment = String.fromEnvironment(
      'ENVIRONMENT',
      defaultValue: Environment.dev,
    );
    setupLocator(environment);
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child,
    );
  }
}
