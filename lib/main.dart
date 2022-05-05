import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:podd_app/services/auth_service.dart';
import 'package:podd_app/ui/home/home_view.dart';
import 'package:podd_app/ui/login/login_view.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked/stacked_annotations.dart';

import 'locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHiveForFlutter();

  const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: Environment.dev,
  );
  setupLocator(environment);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: locator.allReady(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return OverlaySupport.global(
            child: MaterialApp(
              title: 'PODD App',
              localizationsDelegates: const [
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

  @override
  List<ReactiveServiceMixin> get reactiveServices =>
      [authService as AuthService];
}
