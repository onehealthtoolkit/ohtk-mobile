import 'dart:io';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:podd_app/components/fix_screen_util_app_wrapper.dart';
import 'package:podd_app/components/restart_widget.dart';
import 'package:podd_app/services/httpclient.dart';
import 'package:podd_app/ui/app/ohtk_view.dart';
import 'package:stacked/stacked_annotations.dart';

import 'firebase_options.dart';
import 'locator.dart';

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
  setupRemoteConfig(environment);
  setupLocator(environment);

  runApp(
    const RestartWidget(
      child: FixScreenUtilAppWrapper(
        child: OhtkApp(),
      ),
    ),
  );
}

setupRemoteConfig(String environment) async {
  final remoteConfig = FirebaseRemoteConfig.instance;
  if (environment == 'dev') {
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 1),
      minimumFetchInterval: const Duration(minutes: 5),
    ));
  } else {
    // do nothing use default remote config settings
  }
}
