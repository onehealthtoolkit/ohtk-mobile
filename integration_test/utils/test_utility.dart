import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:patrol/patrol.dart';
import 'package:podd_app/components/fix_screen_util_app_wrapper.dart';
import 'package:podd_app/components/restart_widget.dart';
import 'package:podd_app/firebase_options.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/services/httpclient.dart';
import 'package:podd_app/ui/app/ohtk_view.dart';
import 'package:stacked/stacked_annotations.dart';

/// Shared test initializer for all Patrol integration tests.
///
/// Replicates the logic of [main] in lib/main.dart with the two changes
/// required by Patrol (from https://patrol.leancode.co/documentation):
///
///   1. DO NOT call WidgetsFlutterBinding.ensureInitialized() — Patrol's
///      PatrolBinding initializes the binding itself.
///   2. DO NOT call runApp() — use $.pumpWidgetAndSettle() instead so
///      the test engine controls the widget tree.
abstract final class TestUtility {
  TestUtility._();

  /// Initialises all app services and pumps the root widget.
  ///
  /// Call this as the very first await inside every patrolTest callback.
  static Future<void> init(PatrolIntegrationTester $) async {
    HttpOverrides.global = MyHttpOverrides();

    await initHiveForFlutter();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    const environment = String.fromEnvironment(
      'ENVIRONMENT',
      defaultValue: Environment.dev,
    );

    await _setupRemoteConfig(environment);

    final progressStreamController = setupLocator(environment);

    await $.pumpWidgetAndSettle(
      RestartWidget(
        child: FixScreenUtilAppWrapper(
          child: OhtkApp(progressStreamController),
        ),
      ),
    );
  }

  static Future<void> _setupRemoteConfig(String environment) async {
    final remoteConfig = FirebaseRemoteConfig.instance;
    if (environment == Environment.dev) {
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 1),
        minimumFetchInterval: const Duration(minutes: 5),
      ));
    }
  }
}
